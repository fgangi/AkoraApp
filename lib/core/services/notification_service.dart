import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:intl/intl.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
  debugPrint('background notification tapped payload: ${notificationResponse.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin get plugin => _plugin;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // --- 2. THE DEFINITIVE TIMEZONE FIX ---
    tz.initializeTimeZones();
    try {
      // Get the timezone from the native side of the device
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("Timezone successfully initialized to: $timeZoneName");
    } catch (e) {
      debugPrint("Could not get the device timezone, defaulting to UTC. Error: $e");
      // Fallback to UTC if it fails for some reason
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('FOREGROUND NOTIFICATION TAPPED - Payload: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    await _requestPermissions();

    _isInitialized = true;
    debugPrint("NotificationService fully initialized.");
  }

  Future<void> _requestPermissions() async {
    bool? result;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      result = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    debugPrint('Notification permissions request result: $result');
  }

  // --- DEBUG METHOD ---
  Future<void> scheduleTestNotification() async {
    if (!_isInitialized) {
      debugPrint("NotificationService not initialized. Cannot schedule test notification.");
      return;
    }
    
    debugPrint("--- Scheduling a test notification in 5 seconds... ---");
    
    // Explicitly use the now-guaranteed correct local timezone
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    debugPrint("Test notification will fire at: $scheduledDate"); // THIS MUST SHOW THE CORRECT OFFSET

    await _plugin.zonedSchedule(
      9999,
      "Notifica di Prova",
      "Se vedi questo messaggio, le notifiche funzionano!",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails('debug_channel', 'Debug Notifications'),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint("--- Test notification has been scheduled. ---");
  }

  // --- CORE APP SCHEDULING ---
  Future<void> scheduleNotificationForTherapy(Therapy therapy) async {
    if (!_isInitialized) {
      debugPrint("NotificationService not initialized. Cannot schedule therapy notification.");
      return;
    }

    if (therapy.takingFrequency == TakingFrequency.onceDaily) {
      final TimeOfDay scheduledTime = TimeOfDay(hour: therapy.reminderHour, minute: therapy.reminderMinute);

      for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
        final DateTime currentDay = therapy.startDate.add(Duration(days: i));
        
        // Use tz.local, which is now guaranteed to be correct
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

        await _plugin.zonedSchedule(
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
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint('Scheduled notification $dailyId for $scheduledDate');
      }
    }
  }

  Future<void> cancelTherapyNotifications(Therapy therapy) async {
    for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
      final DateTime currentDay = therapy.startDate.add(Duration(days: i));
      int dailyId = _generateDailyId(therapy.id, currentDay);
      await _plugin.cancel(dailyId);
    }
    debugPrint('Cancelled all notifications for therapy ID: ${therapy.id}');
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // Helper to create predictable, unique IDs for each daily notification
  int _generateDailyId(int therapyId, DateTime date) {
    final dayOfYear = int.parse(DateFormat("D").format(date));
    // Multiply therapyId by a large number (e.g., 1000) to avoid collisions
    // between different therapies on the same day.
    return (therapyId * 1000) + dayOfYear;
  }
}