// test/notification_service_test.dart

import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FakeFlutterLocalNotificationsPlugin implements FlutterLocalNotificationsPlugin {

  int zonedScheduleCallCount = 0;
  int cancelCallCount = 0;
  int showCallCount = 0;
  int initializeCallCount = 0;
  int? lastShownId;
  String? lastShownTitle;
  int lastCancelledId = -999;
  bool initializeResult = true;
  bool? permissionResult = true;

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
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCallCount++;
    // Simulate calling the callback if provided
    if (onDidReceiveNotificationResponse != null) {
      // This simulates a notification tap in the foreground
    }
    return initializeResult;
  }

  @override
  T? resolvePlatformSpecificImplementation<T extends FlutterLocalNotificationsPlatform>() {
    if (T == AndroidFlutterLocalNotificationsPlugin) {
      return FakeAndroidNotificationsPlugin() as T?;
    } else if (T == IOSFlutterLocalNotificationsPlugin) {
      return FakeIOSNotificationsPlugin() as T?;
    }
    return null;
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

  // Stub implementations for other required methods
  @override
  Future<void> cancelAllPendingNotifications() async {}

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async => [];

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async => null;

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async => [];

  @override
  Future<void> periodicallyShow(int id, String? title, String? body, RepeatInterval repeatInterval, NotificationDetails notificationDetails, {required AndroidScheduleMode androidScheduleMode, String? payload}) async {}

  @override
  Future<void> periodicallyShowWithDuration(int id, String? title, String? body, Duration repeatDurationInterval, NotificationDetails notificationDetails, {AndroidScheduleMode androidScheduleMode = AndroidScheduleMode.exact, String? payload}) async {}
}

class FakeAndroidNotificationsPlugin implements AndroidFlutterLocalNotificationsPlugin {
  bool? requestResult = true;

  @override
  Future<bool?> requestNotificationsPermission() async {
    return requestResult;
  }

  // Stub other methods - we only need the permission method for our tests
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeIOSNotificationsPlugin implements IOSFlutterLocalNotificationsPlugin {
  bool? requestResult = true;

  @override
  Future<bool?> requestPermissions({bool alert = false, bool badge = false, bool sound = false, bool critical = false, bool provisional = false}) async {
    return requestResult;
  }

  // Stub other methods - we only need the permission method for our tests
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('NotificationService', () {
    late FakeFlutterLocalNotificationsPlugin fakePlugin;
    late NotificationService notificationService;

    // Helper to create a standard therapy object for tests.
    Therapy createTestTherapy({DateTime? expiryDate}) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return Therapy(
          id: 1, drugName: 'Test Drug', drugDosage: '100mg', doseAmount: '1',
          takingFrequency: TakingFrequency.onceDaily, reminderTimes: ['08:00'],
          startDate: today.add(const Duration(days: 1)),
          endDate: today.add(const Duration(days: 1)),
          doseThreshold: 10, isActive: true, isPaused: false,
          expiryDate: expiryDate
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

    group('Initialization Tests', () {
      test('init should complete successfully and set isInitialized to true', () async {
        // Arrange
        final service = NotificationService.testable(fakePlugin);
        expect(service.isInitialized, false);

        // Act
        await service.init();

        // Assert
        expect(service.isInitialized, true);
        expect(fakePlugin.initializeCallCount, 1);
      });

      test('init should not reinitialize if already initialized', () async {
        // Arrange
        final service = NotificationService.testable(fakePlugin);
        await service.init();
        final firstInitCount = fakePlugin.initializeCallCount;

        // Act - call init again
        await service.init();

        // Assert - should not call initialize again
        expect(fakePlugin.initializeCallCount, firstInitCount);
        expect(service.isInitialized, true);
      });

      test('factory constructor returns singleton instance', () {
        // Act
        final service1 = NotificationService();
        final service2 = NotificationService();

        // Assert
        expect(identical(service1, service2), true);
      });

      test('plugin getter returns the correct plugin instance', () {
        // Act
        final plugin = notificationService.plugin;

        // Assert
        expect(plugin, equals(fakePlugin));
      });
    });

    group('Background Notification Handler Tests', () {
      test('onDidReceiveBackgroundNotificationResponse handles notification tap', () {
        // Arrange - Create a notification response
        const notificationResponse = NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: 'test_payload',
        );

        // Act & Assert - Should not throw
        expect(() => onDidReceiveBackgroundNotificationResponse(notificationResponse), returnsNormally);
      });
    });

    group('Permission Request Tests', () {
      test('init requests Android permissions when successful', () async {
        // Arrange
        final service = NotificationService.testable(fakePlugin);
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        // Act
        await service.init();

        // Assert
        expect(service.isInitialized, true);

        // Cleanup
        debugDefaultTargetPlatformOverride = null;
      });

      test('init requests iOS permissions when successful', () async {
        // Arrange
        final service = NotificationService.testable(fakePlugin);
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        // Act
        await service.init();

        // Assert
        expect(service.isInitialized, true);

        // Cleanup
        debugDefaultTargetPlatformOverride = null;
      });

      test('init handles permission denial gracefully', () async {
        // Arrange
        final service = NotificationService.testable(fakePlugin);
        // Set the fake plugin to return false for permissions
        if (fakePlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() 
            is FakeAndroidNotificationsPlugin) {
          (fakePlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() 
              as FakeAndroidNotificationsPlugin).requestResult = false;
        }

        // Act & Assert - Should not throw even if permissions denied
        await expectLater(service.init(), completes);
        expect(service.isInitialized, true);
      });
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

    test('edit a therapy skips scheduling past times but still cancels previous reminders', () async {
      // Arrange: therapy scheduled for TODAY but at a time that already passed
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      final pastTimeString = '08:00';

      final therapy = Therapy(
        id: 42,
        drugName: 'Past Drug',
        drugDosage: '10mg',
        doseAmount: '1',
        takingFrequency: TakingFrequency.onceDaily,
        reminderTimes: [pastTimeString],
        startDate: yesterday,
        endDate: yesterday,
        doseThreshold: 5,
        isActive: true,
        isPaused: false,
      );

      // Act
      await notificationService.scheduleNotificationForTherapy(therapy);

      // Assert:
      // - cancel should be called for main + snooze + expiry (3)
      // - zonedSchedule should NOT be called because the scheduled time is in the past
      expect(fakePlugin.cancelCallCount, 3);
      expect(fakePlugin.zonedScheduleCallCount, 0);
    });

    test('twiceDaily create reminders twice a day every day', () async {
      // Arrange: start in the future to ensure times are not in the past
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final dayAfter = tomorrow.add(const Duration(days: 1));
      final therapy = Therapy(
        id: 7,
        drugName: 'MultiDay Drug',
        drugDosage: '20mg',
        doseAmount: '1',
        takingFrequency: TakingFrequency.twiceDaily,
        reminderTimes: ['08:00', '20:00'],
        startDate: tomorrow,
        endDate: dayAfter, // two days total
        doseThreshold: 2,
        isActive: true,
        isPaused: false,
      );

      fakePlugin.cancelCallCount = 0;
      fakePlugin.zonedScheduleCallCount = 0;

      // Act
      await notificationService.scheduleNotificationForTherapy(therapy);

      // Assert:
      // cancelCallCount: for each time (2) * each day (2) * (main + snooze = 2) + expiry (1)
      // => 2 * 2 * 2 + 1 = 9
      expect(fakePlugin.cancelCallCount, 9);
      // zonedScheduleCallCount: 2 times * 2 days = 4 scheduled notifications
      expect(fakePlugin.zonedScheduleCallCount, 4);
    });

    test('expire date notification', () async {
      // Arrange
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 10));
      final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      final therapy = Therapy(
        id: 11,
        drugName: 'Expiry Drug',
        drugDosage: '5mg',
        doseAmount: '1',
        takingFrequency: TakingFrequency.onceDaily,
        reminderTimes: ['09:00'],
        startDate: tomorrow,
        endDate: tomorrow,
        expiryDate: expiryDate,
        doseThreshold: 1,
        isActive: true,
        isPaused: false,
      );

      fakePlugin.cancelCallCount = 0;
      fakePlugin.zonedScheduleCallCount = 0;

      // Act
      await notificationService.scheduleExpiryNotification(therapy);

      expect(fakePlugin.cancelCallCount, 1);
      expect(fakePlugin.zonedScheduleCallCount, 1);
    });

    test('cancelAllNotifications delete all previously scheduled notifications', () async {
      // Arrange
      fakePlugin.cancelCallCount = 0;

      // Act
      await notificationService.cancelAllNotifications();

      // Assert
      expect(fakePlugin.cancelCallCount, 999);
    });

    test('onceWeekly only schedules on notification on matching weekday', () async {
      // Arrange
      final now = DateTime.now();
      // find next week day
      int daysToWed = (DateTime.wednesday - now.weekday) % 7;
      if (daysToWed <= 0) daysToWed += 7;
      final nextWednesday = DateTime(now.year, now.month, now.day).add(Duration(days: daysToWed));
      final endDate = nextWednesday.add(const Duration(days: 6)); // one-week range
      final therapy = Therapy(
        id: 99,
        drugName: 'Weekly Drug',
        drugDosage: '1mg',
        doseAmount: '1',
        takingFrequency: TakingFrequency.onceWeekly,
        reminderTimes: ['10:00'],
        startDate: nextWednesday,
        endDate: endDate,
        doseThreshold: 1,
        isActive: true,
        isPaused: false,
      );

      fakePlugin.cancelCallCount = 0;
      fakePlugin.zonedScheduleCallCount = 0;

      // Act
      await notificationService.scheduleNotificationForTherapy(therapy);

      // Assert:
      // cancelCallCount: timeCount(1) * daysCount(7) * 2 (main + snooze) + expiry(1) = 1*7*2 +1 = 15
      expect(fakePlugin.cancelCallCount, 15);
      expect(fakePlugin.zonedScheduleCallCount, 1);
    });

    group('Edge Cases and Error Handling', () {
      test('scheduleNotificationForTherapy handles therapy with no reminder times', () async {
        // Arrange
        final therapy = createTestTherapy();
        therapy.reminderTimes.clear();

        // Act & Assert - Should not throw
        await expectLater(notificationService.scheduleNotificationForTherapy(therapy), completes);
      });

      test('scheduleExpiryNotification handles therapy without expiry date', () async {
        // Arrange
        final therapy = createTestTherapy(); // No expiry date

        // Act & Assert - Should not throw and should not schedule anything
        await expectLater(notificationService.scheduleExpiryNotification(therapy), completes);
        expect(fakePlugin.zonedScheduleCallCount, 0);
      });

      test('scheduleExpiryNotification handles therapy with empty reminder times', () async {
        // Arrange
        final now = DateTime.now();
        final therapy = Therapy(
          id: 1,
          drugName: 'Test Drug',
          drugDosage: '100mg',
          doseAmount: '1',
          takingFrequency: TakingFrequency.onceDaily,
          reminderTimes: [], // Empty reminder times
          startDate: now.add(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 1)),
          doseThreshold: 10,
          isActive: true,
          isPaused: false,
          expiryDate: now.add(const Duration(days: 10)),
        );

        // Act & Assert - Should not throw and should not schedule anything
        await expectLater(notificationService.scheduleExpiryNotification(therapy), completes);
        expect(fakePlugin.zonedScheduleCallCount, 0);
      });

      test('scheduling when not initialized prints warning and returns early', () async {
        // Arrange
        final service = NotificationService.testable(fakePlugin);
        expect(service.isInitialized, false);
        final therapy = createTestTherapy();

        // Act
        await service.scheduleNotificationForTherapy(therapy);

        // Assert - Should not have called any scheduling methods
        expect(fakePlugin.zonedScheduleCallCount, 0);
        expect(fakePlugin.cancelCallCount, 0);
      });

      test('triggerLowStockNotification uses correct ID format', () async {
        // Arrange
        const therapyId = 123;

        // Act
        await notificationService.triggerLowStockNotification(
          therapyId: therapyId,
          drugName: 'Test Drug',
          remainingDoses: 2,
        );

        // Assert
        expect(fakePlugin.lastShownId, equals(-therapyId));
        expect(fakePlugin.lastShownTitle, contains('Scorte in Esaurimento'));
      });

      test('cancelLowStockNotification uses correct ID format', () async {
        // Arrange
        const therapyId = 456;

        // Act
        await notificationService.cancelLowStockNotification(therapyId);

        // Assert
        expect(fakePlugin.lastCancelledId, equals(-therapyId));
      });
    });

    group('Comprehensive Scheduling Tests', () {
      test('multiple reminder times on same day schedules multiple notifications', () async {
        // Arrange
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        final therapy = Therapy(
          id: 50,
          drugName: 'Multi-time Drug',
          drugDosage: '5mg',
          doseAmount: '2',
          takingFrequency: TakingFrequency.twiceDaily,
          reminderTimes: ['08:00', '14:00', '20:00'],
          startDate: tomorrow,
          endDate: tomorrow,
          doseThreshold: 5,
          isActive: true,
          isPaused: false,
        );

        fakePlugin.cancelCallCount = 0;
        fakePlugin.zonedScheduleCallCount = 0;

        // Act
        await notificationService.scheduleNotificationForTherapy(therapy);

        // Assert - Should schedule 3 notifications (one for each time)
        expect(fakePlugin.zonedScheduleCallCount, 3);
      });

      test('therapy spanning multiple days with weekly frequency', () async {
        // Arrange
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
        final endDate = startDate.add(const Duration(days: 14)); // 3 weeks
        final therapy = Therapy(
          id: 75,
          drugName: 'Long Term Drug',
          drugDosage: '10mg',
          doseAmount: '1',
          takingFrequency: TakingFrequency.onceWeekly,
          reminderTimes: ['09:00'],
          startDate: startDate,
          endDate: endDate,
          doseThreshold: 3,
          isActive: true,
          isPaused: false,
        );

        fakePlugin.cancelCallCount = 0;
        fakePlugin.zonedScheduleCallCount = 0;

        // Act
        await notificationService.scheduleNotificationForTherapy(therapy);

        // Assert - Should schedule 3 notifications (once per week for 3 weeks)
        expect(fakePlugin.zonedScheduleCallCount, 3);
      });

      test('expiry notification scheduled 7 days before expiry date', () async {
        // Arrange
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 10));
        final therapy = createTestTherapy(expiryDate: futureDate);

        fakePlugin.cancelCallCount = 0;
        fakePlugin.zonedScheduleCallCount = 0;

        // Act
        await notificationService.scheduleExpiryNotification(therapy);

        // Assert
        expect(fakePlugin.cancelCallCount, 1); // Cancel existing expiry notification
        expect(fakePlugin.zonedScheduleCallCount, 1); // Schedule new expiry notification
      });
    });
  });
}