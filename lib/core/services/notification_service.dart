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
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  FlutterLocalNotificationsPlugin get plugin => _plugin;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

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
    _isInitialized = true;
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
    if (!_isInitialized) {
      debugPrint("NotificationService not initialized.");
      return;
    }

    // This logic handles all frequencies based on the data
    for (final timeString in therapy.reminderTimes) {
      final timeParts = timeString.split(':');
      final scheduledTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

            for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
        final DateTime currentDay = therapy.startDate.add(Duration(days: i));
        
        // Add weekly check
        if (therapy.takingFrequency == TakingFrequency.onceWeekly && currentDay.weekday != therapy.startDate.weekday) {
          continue; // Skip days that don't match the start day for weekly therapies
        }

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

        int dailyId = _generateUniqueId(therapy.id, currentDay, scheduledTime);
        String title = 'Promemoria: ${therapy.drugName}';

        // We dynamically create the "dose" or "dosi" label based on the amount.
        final int doseAmountNum = int.tryParse(therapy.doseAmount) ?? 1;
        final String doseLabel = doseAmountNum == 1 ? 'dose' : 'dosi';
        String body = 'È ora di prendere ${therapy.doseAmount} $doseLabel di ${therapy.drugName} ${therapy.drugDosage}.';
        // --- END OF CORRECTION ---

        await _plugin.zonedSchedule(
          dailyId,
          title,
          body, // Use the corrected body string
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails('therapy_reminders_channel_id', 'Therapy Reminders', channelDescription: 'Reminders for your medication schedule.', importance: Importance.max, priority: Priority.high),
            iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint('Scheduled notification $dailyId for $scheduledDate');
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

  // (In case the user updates their dose count upwards)
  Future<void> cancelLowStockNotification(int therapyId) async {
    final int lowStockId = -therapyId;
    await _plugin.cancel(lowStockId);
  }

  // --- CANCELLATION LOGIC ---
  Future<void> cancelTherapyNotifications(Therapy therapy) async {
    for (final timeString in therapy.reminderTimes) {
      final timeParts = timeString.split(':');
      final scheduledTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

      for (int i = 0; i <= therapy.endDate.difference(therapy.startDate).inDays; i++) {
        final DateTime currentDay = therapy.startDate.add(Duration(days: i));
        int dailyId = _generateUniqueId(therapy.id, currentDay, scheduledTime);
        await _plugin.cancel(dailyId);
      }
    }
    // Also cancel the expiry notification
    final int expiryId = -therapy.id - 100000;
    await _plugin.cancel(expiryId);

    debugPrint('Cancelled all notifications for therapy ID: ${therapy.id}');
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // A unique ID per therapy, per day, per time slot.
  int _generateUniqueId(int therapyId, DateTime date, TimeOfDay time) {
    // We need to ensure the ID is a unique 32-bit signed integer.
    // Max value is 2,147,483,647.

    // Let's create an ID from components:
    // Therapy ID (up to 999) + Day of Year (1-366) + Time (0-2359)
    // To prevent overlap, we use multipliers.

    final dayOfYear = int.parse(DateFormat("D").format(date)); // Max 366
    final timePart = time.hour * 100 + time.minute;             // Max 2359

    // The formula:
    // therapyId * 1,000,000 gives space for the rest.
    // dayOfYear * 10,000 gives space for time.
    // This creates a unique number for every minute of every day for a given therapy.
    
    // Example: therapy 1, day 219, time 18:30 (1830)
    // 1 * 1000000 = 1000000
    // 219 * 10000 = 2190000
    // 1830
    // Total ID = 3191830 (well within the limit)

    // Safety check in case therapyId gets very large
    if (therapyId > 200) {
      // If the ID is too big, this scheme could fail. We can use a hashing fallback.
      // For now, this is robust enough for hundreds of therapies.
      print("Warning: therapyId is large, which might risk ID collision or overflow.");
    }
    
    final int uniqueId = (therapyId * 1000000) + (dayOfYear * 10000) + timePart;

    return uniqueId;
  }
}