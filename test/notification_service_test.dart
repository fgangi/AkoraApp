// test/notification_service_test.dart

import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FakeFlutterLocalNotificationsPlugin implements FlutterLocalNotificationsPlugin {

  int zonedScheduleCallCount = 0;
  int cancelCallCount = 0;
  int showCallCount = 0;
  int? lastShownId;
  String? lastShownTitle;
  int lastCancelledId = -999;

  @override
  Future<void> cancel(int id, {String? tag}) async {
    cancelCallCount++;
    lastCancelledId = id;
  }

  @override
  Future<void> cancelAll() async {
    cancelCallCount = 999;
  }

  @override
  Future<void> cancelAllPendingNotifications() {
    // TODO: implement cancelAllPendingNotifications
    throw UnimplementedError();
  }

  @override
  Future<List<ActiveNotification>> getActiveNotifications() {
    // TODO: implement getActiveNotifications
    throw UnimplementedError();
  }

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() {
    // TODO: implement getNotificationAppLaunchDetails
    throw UnimplementedError();
  }

  @override
  Future<bool?> initialize(InitializationSettings initializationSettings, {DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse, DidReceiveBackgroundNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse}) {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    // TODO: implement pendingNotificationRequests
    throw UnimplementedError();
  }

  @override
  Future<void> periodicallyShow(int id, String? title, String? body, RepeatInterval repeatInterval, NotificationDetails notificationDetails, {required AndroidScheduleMode androidScheduleMode, String? payload}) {
    // TODO: implement periodicallyShow
    throw UnimplementedError();
  }

  @override
  Future<void> periodicallyShowWithDuration(int id, String? title, String? body, Duration repeatDurationInterval, NotificationDetails notificationDetails, {AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exact, String? payload}) {
    // TODO: implement periodicallyShowWithDuration
    throw UnimplementedError();
  }

  @override
  T? resolvePlatformSpecificImplementation<T extends FlutterLocalNotificationsPlatform>() {
    // TODO: implement resolvePlatformSpecificImplementation
    throw UnimplementedError();
  }

  @override
  Future<void> show(int id, String? title, String? body, NotificationDetails? notificationDetails, {String? payload}) async {
    showCallCount++;
    lastShownId = id;
    lastShownTitle = title;
  }

  @override
  Future<void> zonedSchedule(int id, String? title, String? body, tz.TZDateTime scheduledDate, NotificationDetails notificationDetails, {required AndroidScheduleMode androidScheduleMode, String? payload, DateTimeComponents? matchDateTimeComponents}) async {
    zonedScheduleCallCount++;
    
  }
  // The body is completely empty.
}

void main() {
  group('NotificationService', () {
    late FakeFlutterLocalNotificationsPlugin fakePlugin;
    late NotificationService notificationService;

    // Helper to create a standard therapy object for tests.
    Therapy createTestTherapy() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return Therapy(
          id: 1, drugName: 'Test Drug', drugDosage: '100mg', doseAmount: '1',
          takingFrequency: TakingFrequency.onceDaily, reminderTimes: ['08:00'],
          startDate: today.add(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 1)),
          doseThreshold: 10, isActive: true, isPaused: false
      );
    }

    // This runs before each test, ensuring a clean slate.
    setUp(() {
      // Create a fresh instance of our fake plugin.
      fakePlugin = FakeFlutterLocalNotificationsPlugin();
      // Inject our fake plugin using the testable constructor.
      notificationService = NotificationService.testable(fakePlugin);
      
      // Initialize timezone data, which is a required setup step for the service.
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC')); // Use UTC for predictable test results
      notificationService.isInitialized = true;
    });

    test('scheduleNotificationForTherapy should schedule one notification for a one-day therapy', () async {
      // Arrange
      final therapy = createTestTherapy();
      
      // Act
      await notificationService.scheduleNotificationForTherapy(therapy);

      // Assert
      // The service should cancel old notifications first (3 calls: main, snooze, expiry)
      // and then schedule one new notification.
      expect(fakePlugin.cancelCallCount, 3);
      expect(fakePlugin.zonedScheduleCallCount, 1);
    });

    test('cancelTherapyNotifications should cancel all potential notifications for a therapy', () async {
      // Arrange
      final therapy = createTestTherapy();

      // Act
      await notificationService.cancelTherapyNotifications(therapy);

      // Assert
      // Main + Snooze notifications for the one day = 2
      // Expiry notification = 1
      // Total = 3 cancel calls.
      expect(fakePlugin.cancelCallCount, 3);
    });

    test('cancelTodaysDoseNotification should cancel main and snooze notifications for a specific time', () async {
      // Arrange
      const therapyId = 1;
      final doseTime = TimeOfDay(hour: 8, minute: 0);
      
      // Act
      await notificationService.cancelTodaysDoseNotification(therapyId, doseTime);
      
      // Assert
      // The method should cancel exactly two notifications: the main one and its potential snooze.
      expect(fakePlugin.cancelCallCount, 2);
    });
    
    test('triggerLowStockNotification should call plugin.show with correct details', () async {
      // Arrange (no arrangement needed for this simple case)
          
      // Act
      await notificationService.triggerLowStockNotification(
        therapyId: 1,
        drugName: 'Test Drug',
        remainingDoses: 5,
      );
      
      // Assert
      // We check our counters and the stored variables in our fake class.
      expect(fakePlugin.showCallCount, 1);
      expect(fakePlugin.lastShownId, -1); // ID is -therapyId
      expect(fakePlugin.lastShownTitle, 'Scorte in Esaurimento: Test Drug');
    });

    test('cancelLowStockNotification should call plugin.cancel with correct ID', () async {
      // Arrange
      const therapyId = 1;

      // Act
      await notificationService.cancelLowStockNotification(therapyId);

      // Assert
      expect(fakePlugin.cancelCallCount, 1);
      expect(fakePlugin.lastCancelledId, -1); // ID is -therapyId
    });
  });
}