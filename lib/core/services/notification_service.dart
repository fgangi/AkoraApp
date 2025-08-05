import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:akora_app/data/sources/local/app_database.dart'; // For using Therapy object

// This callback needs to be a top-level function for background handling
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
  debugPrint('background notification payload: ${notificationResponse.payload}');
}

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        debugPrint('notification tapped payload: ${notificationResponse.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // ... (This method is correct and remains the same)
  }

  // --- SCHEDULING METHOD (CORRECTED) ---
  Future<void> scheduleNotificationForTherapy(Therapy therapy) async {
    // This is a more robust way to handle scheduling for a whole therapy object
    final TimeOfDay scheduledTime = TimeOfDay(hour: therapy.reminderHour, minute: therapy.reminderMinute);

    for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
      final DateTime currentDay = therapy.startDate.add(Duration(days: i));
      final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        currentDay.year,
        currentDay.month,
        currentDay.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        continue;
      }

      int dailyId = _generateDailyId(therapy.id, currentDay);
      String title = 'Promemoria: ${therapy.drugName}';
      String body = 'È ora di prendere la tua dose di ${therapy.drugDosage}.';

      await flutterLocalNotificationsPlugin.zonedSchedule(
        dailyId,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'therapy_reminders_channel_id',
            'Therapy Reminders',
            channelDescription: 'Reminders for your medication schedule.',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // The 'uiLocalNotificationDateInterpretation' parameter is REMOVED.
        // The behavior is now determined by the TZDateTime object itself.
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Scheduled notification $dailyId for $scheduledDate');
    }
  }

  // --- CANCEL & RESCHEDULE LOGIC ---

  Future<void> cancelTherapyNotifications(Therapy therapy) async {
    for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
      final DateTime currentDay = therapy.startDate.add(Duration(days: i));
      int dailyId = _generateDailyId(therapy.id, currentDay);
      await flutterLocalNotificationsPlugin.cancel(dailyId);
    }
    debugPrint('Cancelled all notifications for therapy ID: ${therapy.id}');
  }
  
  Future<void> rescheduleAllNotifications(List<Therapy> therapies) async {
    await cancelAllNotifications();
    for (final therapy in therapies) {
      if (therapy.takingFrequency == TakingFrequency.onceDaily) { // Check frequency
        await scheduleNotificationForTherapy(therapy);
      }
      // TODO: Add logic for other frequencies if needed
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  int _generateDailyId(int therapyId, DateTime date) {
    // A simple, predictable ID generation scheme.
    // Format: YYYYMMDDHHII (Year, Month, Day, Hour, Minute)
    // To make it unique per therapy, we can use the therapy ID.
    // Let's use a simpler scheme to avoid integer overflow:
    // TherapyID + day of the year.
    final dayOfYear = int.parse(DateFormat("D").format(date));
    // Multiply therapyId by a large number (e.g., 1000) to avoid collisions.
    return (therapyId * 1000) + dayOfYear;
  }
}