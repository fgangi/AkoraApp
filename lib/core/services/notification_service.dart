import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:intl/intl.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
  debugPrint('background notification tapped payload: ${notificationResponse.payload}');
}

class NotificationService {
  late FlutterLocalNotificationsPlugin _plugin;
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    // --- The real app will use this constructor ---
    _plugin = FlutterLocalNotificationsPlugin();
  }

  @visibleForTesting
  NotificationService.testable(this._plugin);

  bool isInitialized = false;

  Future<void> init() async {
    if (isInitialized) return;

    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("Timezone successfully initialized to: $timeZoneName");
    } catch (e) {
      debugPrint("Could not get the device timezone, defaulting to UTC. Error: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: darwinSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('FOREGROUND NOTIFICATION TAPPED - Payload: ${response.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    await _requestPermissions();
    isInitialized = true;
    debugPrint("NotificationService fully initialized.");
  }

  Future<void> _requestPermissions() async {
    bool? result;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      result = await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      result = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
    debugPrint('Notification permissions request result: $result');
  }

  // --- CORE APP SCHEDULING ---
  Future<void> scheduleNotificationForTherapy(Therapy therapy) async {
    if (!isInitialized) {
      debugPrint("NotificationService not initialized. Cannot schedule.");
      return;
    }
    
    // Always cancel old notifications before scheduling new ones.
    await cancelTherapyNotifications(therapy);
    print("Cancelled old notifications for Therapy ID: ${therapy.id}, now rescheduling.");

    // Loop through each reminder time saved for the therapy (e.g., ["08:30", "20:00"])
    for (final timeString in therapy.reminderTimes) {
      final timeParts = timeString.split(':');
      final scheduledTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

      // Loop through each day in the therapy's duration
      for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
        final DateTime currentDay = therapy.startDate.add(Duration(days: i));
        
        // --- FREQUENCY LOGIC ---
        bool shouldScheduleToday = false;
        switch (therapy.takingFrequency) {
          case TakingFrequency.onceDaily:
          case TakingFrequency.twiceDaily:
            // For daily frequencies, we schedule on every day in the range.
            shouldScheduleToday = true;
            break;
          case TakingFrequency.onceWeekly:
            // For weekly, we only schedule if the current day's weekday
            // matches the start date's weekday.
            if (currentDay.weekday == therapy.startDate.weekday) {
              shouldScheduleToday = true;
            }
            break;
        }

        if (!shouldScheduleToday) {
          continue; // Skip to the next day if it doesn't match the frequency
        }
        
        // --- The rest of the scheduling logic ---
        final tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          currentDay.year,
          currentDay.month,
          currentDay.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );

        if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
          continue; // Don't schedule for past times
        }

        int uniqueId = _generateUniqueId(therapy.id, currentDay, scheduledTime);
        String title = 'Promemoria: ${therapy.drugName}';
        String body = 'È ora di prendere ${therapy.doseAmount} ${int.tryParse(therapy.doseAmount) == 1 ? "dose" : "dosi"} di ${therapy.drugName}.';

        await _plugin.zonedSchedule(
          uniqueId,
          title,
          body,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails('therapy_reminders_channel_id', 'Therapy Reminders', channelDescription: 'Reminders for your medication schedule.', importance: Importance.max, priority: Priority.high),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint('Scheduled notification $uniqueId for $scheduledDate');
      }
    }
  }

  // --- EXPIRY NOTIFICATION ---
  Future<void> scheduleExpiryNotification(Therapy therapy) async {
    final int expiryId = -therapy.id - 100000; // Use a predictable negative ID
    await _plugin.cancel(expiryId);

    if (therapy.expiryDate == null || therapy.reminderTimes.isEmpty) return;

    final notificationDate = therapy.expiryDate!.subtract(const Duration(days: 7));
    final firstTimeParts = therapy.reminderTimes[0].split(':');
    final scheduledTime = TimeOfDay(hour: int.parse(firstTimeParts[0]), minute: int.parse(firstTimeParts[1]));

    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      // Logic for immediate notification if expiry is soon can be added here
      return;
    }

    final String title = 'Farmaco in Scadenza: ${therapy.drugName}';
    final String body = 'La tua confezione di ${therapy.drugName} scadrà il ${DateFormat('dd/MM/yyyy').format(therapy.expiryDate!)}.';

    await _plugin.zonedSchedule(
      expiryId,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails('expiry_alerts_channel_id', 'Avvisi di Scadenza', channelDescription: 'Notifiche per farmaci in scadenza.', importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint('Scheduled expiry notification $expiryId for $scheduledDate');
  }

  Future<void> triggerLowStockNotification({
    required int therapyId,
    required String drugName,
    required int remainingDoses,
  }) async {
    // A predictable negative ID to prevent clashes and allow cancellation.
    final int lowStockId = -therapyId;

    // We use plugin.show() to display the notification immediately.
    await _plugin.show(
      lowStockId,
      'Scorte in Esaurimento: $drugName',
      'Sono rimaste solo $remainingDoses dosi. Ricorda di acquistare una nuova confezione.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'low_stock_channel_id',
          'Avvisi Scorte in Esaurimento',
          channelDescription: 'Notifiche per farmaci in esaurimento.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'low_stock_$therapyId',
    );
    debugPrint('Triggered low stock notification for therapy ID: $therapyId');
  }

  // --- CANCELLATION LOGIC ---
  // (In case the user updates their dose count upwards)
  Future<void> cancelLowStockNotification(int therapyId) async {
    final int lowStockId = -therapyId;
    await _plugin.cancel(lowStockId);
  }

  /// Cancels only TODAY's notifications for a single dose time.
  /// Used when a user marks a dose as taken.
  Future<void> cancelTodaysDoseNotification(int therapyId, TimeOfDay doseTime) async {
    final today = DateTime.now();
    
    // Generate the IDs for ONLY today's notifications for this specific time.
    int mainId = _generateUniqueId(therapyId, today, doseTime, isSnooze: false);
    int snoozeId = _generateUniqueId(therapyId, today, doseTime, isSnooze: true);

    // Cancel both.
    await _plugin.cancel(mainId);
    await _plugin.cancel(snoozeId);
    
    debugPrint('Precisely cancelled today\'s notifications for therapy $therapyId at $doseTime. IDs: $mainId, $snoozeId');
  }

  /// Cancels ALL scheduled notifications (daily reminders, potential snoozes, and expiry)
  /// for a single therapy. This is the main, robust method to use.
  Future<void> cancelTherapyNotifications(Therapy therapy) async {
    // 1. Cancel all daily reminders and their potential snoozes
    for (final timeString in therapy.reminderTimes) {
      final timeParts = timeString.split(':');
      final scheduledTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

      for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
        final DateTime currentDay = therapy.startDate.add(Duration(days: i));
        // Cancel the main notification for this slot
        await _plugin.cancel(_generateUniqueId(therapy.id, currentDay, scheduledTime, isSnooze: false));
        // Also cancel the snooze notification for this slot
        await _plugin.cancel(_generateUniqueId(therapy.id, currentDay, scheduledTime, isSnooze: true));
      }
    }
    
    // 2. Also cancel the expiry notification
    final int expiryId = -therapy.id - 100000;
    await _plugin.cancel(expiryId);

    debugPrint('Successfully cancelled all potential notifications for therapy ID: ${therapy.id}');
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
  
  // This unique ID generation is correct.
  int _generateUniqueId(int therapyId, DateTime date, TimeOfDay time, {bool isSnooze = false}) {
    final dayOfYear = int.parse(DateFormat("D").format(date));
    final timePart = time.hour * 100 + time.minute;
    final baseId = (therapyId * 1000000) + (dayOfYear * 10000) + timePart;
    // Using a different multiplier ensures snooze IDs are in a completely different range.
    return isSnooze ? baseId + 1000000000 : baseId;
  }
}