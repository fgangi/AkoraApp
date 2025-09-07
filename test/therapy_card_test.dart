// test/therapy_card_test.dart

import 'dart:async';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/widgets/dose_status_icon.dart';
import 'package:akora_app/features/home/widgets/therapy_card.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/src/flutter_local_notifications_plugin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

// Import the generated mocks
import 'home_screen_test.mocks.dart';

//fake implementation of NotificationService 
class FakeNotificationService implements NotificationService {
  final List<Map<String, dynamic>> cancelledCalls = [];
  final List<Map<String, dynamic>> lowStockCalls = [];
  final List<Therapy> scheduledCalls = [];

  @override
  Future<void> cancelTodaysDoseNotification(int therapyId, TimeOfDay doseTime) async {
    cancelledCalls.add({'therapyId': therapyId, 'doseTime': doseTime});
    return;
  }

  @override
  Future<void> triggerLowStockNotification({
    required int therapyId,
    required String drugName,
    required int remainingDoses,
  }) async {
    lowStockCalls.add({
      'therapyId': therapyId,
      'drugName': drugName,
      'remainingDoses': remainingDoses,
    });
    return;
  }

  @override
  Future<void> scheduleNotificationForTherapy(Therapy therapy) async {
    scheduledCalls.add(therapy);
    return;
  }

   @override
  Future<void> init() async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> cancelLowStockNotification(int therapyId) async {}

  @override
  late bool isInitialized;

  @override
  Future<void> cancelTherapyNotifications(Therapy therapy) {
    // TODO: implement cancelTherapyNotifications
    throw UnimplementedError();
  }

  @override
  // TODO: implement plugin
  FlutterLocalNotificationsPlugin get plugin => throw UnimplementedError();

  @override
  Future<void> scheduleExpiryNotification(Therapy therapy) {
    // TODO: implement scheduleExpiryNotification
    throw UnimplementedError();
  }
}

void main() {
  // Mocks and fakes
  late MockAppDatabase mockDatabase;
  late FakeNotificationService fakeNotificationService;
  late StreamController<List<MedicationLog>> logsStreamController;

  // Helper to create a test Therapy instance
  Therapy createTestTherapy({
    int dosesRemaining = 20,
    int doseThreshold = 10,
    List<String> reminderTimes = const ['08:00'],
  }) {
    return Therapy(
      id: 1,
      drugName: 'Test Drug',
      drugDosage: '100mg',
      doseAmount: '1',
      takingFrequency: TakingFrequency.onceDaily,
      reminderTimes: reminderTimes,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      doseThreshold: doseThreshold,
      isActive: true,
      isPaused: false,
      dosesRemaining: dosesRemaining,
    );
  }

  // Helper to pump the card widget
 Future<void> pumpTherapyCard(WidgetTester tester, {required Therapy therapy}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => CupertinoPageScaffold(
          child: Center(
            child: TherapyCard(
              therapy: therapy,
              database: mockDatabase,
              notificationService: fakeNotificationService,
              onTap: () {},
            ),
          ),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => CupertinoTheme(
        data: const CupertinoThemeData(),
        child: child!,
      ),
    ),
  );
}

  setUp(() {
    mockDatabase = MockAppDatabase();
    fakeNotificationService = FakeNotificationService();
    logsStreamController = StreamController<List<MedicationLog>>.broadcast();

    // Default DB behavior
    when(mockDatabase.watchDoseLogsForDay(therapyId: anyNamed('therapyId'), day: anyNamed('day')))
        .thenAnswer((_) => logsStreamController.stream);

    when(mockDatabase.logDoseTaken(
      therapyId: anyNamed('therapyId'),
      scheduledTime: anyNamed('scheduledTime'),
      amount: anyNamed('amount'),
    )).thenAnswer((_) async {});

    when(mockDatabase.removeDoseLog(
      therapyId: anyNamed('therapyId'),
      scheduledTime: anyNamed('scheduledTime'),
      amount: anyNamed('amount'),
    )).thenAnswer((_) async {});
  });

  tearDown(() {
    logsStreamController.close();
  });

  group('TherapyCard Logic (with FakeNotificationService)', () {
    testWidgets('tapping an untaken icon calls logDoseTaken and cancelTodaysDoseNotification',
        (tester) async {
      // Arrange
      final therapy = createTestTherapy();
      await pumpTherapyCard(tester, therapy: therapy);

      // No logs => dose is untaken
      logsStreamController.add([]);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(DoseStatusIcon).first);
      await tester.pumpAndSettle();

      // Assert
      verify(mockDatabase.logDoseTaken(
        therapyId: therapy.id,
        scheduledTime: anyNamed('scheduledTime'),
        amount: 1,
      )).called(1);

      expect(fakeNotificationService.cancelledCalls.length, 1);
      final recorded = fakeNotificationService.cancelledCalls.first;
      expect(recorded['therapyId'], therapy.id);
      expect(recorded['doseTime'], isA<TimeOfDay>());
    });

    testWidgets('tapping a taken icon calls removeDoseLog and scheduleNotificationForTherapy',
        (tester) async {
      // Arrange
      final therapy = createTestTherapy();
      await pumpTherapyCard(tester, therapy: therapy);

      // Simulate that the 08:00 dose was already taken.
      final now = DateTime.now();
      logsStreamController.add([
        MedicationLog(
          id: 1,
          therapyId: 1,
          scheduledDoseTime: DateTime(now.year, now.month, now.day, 8, 0),
          actualTakenTime: now,
          status: 'taken',
        )
      ]);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(DoseStatusIcon).first);
      await tester.pumpAndSettle();

      // Assert DB remove called
      verify(mockDatabase.removeDoseLog(
        therapyId: therapy.id,
        scheduledTime: anyNamed('scheduledTime'),
        amount: 1,
      )).called(1);

      // Assert fake scheduled call recorded
      expect(fakeNotificationService.scheduledCalls.length, 1);
      expect(fakeNotificationService.scheduledCalls.first, therapy);
    });

    testWidgets('marking as taken triggers low stock notification when threshold is reached',
        (tester) async {
      // Arrange: have 11 doses remaining and threshold 10
      final therapy = createTestTherapy(dosesRemaining: 11, doseThreshold: 10);
      await pumpTherapyCard(tester, therapy: therapy);

      logsStreamController.add([]);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(DoseStatusIcon).first);
      await tester.pumpAndSettle();

      // Assert that fake low-stock was called with remainingDoses == 10
      expect(fakeNotificationService.lowStockCalls.length, 1);
      final call = fakeNotificationService.lowStockCalls.first;
      expect(call['therapyId'], therapy.id);
      expect(call['drugName'], therapy.drugName);
      expect(call['remainingDoses'], 10);
    });

    testWidgets('remaining doses text is hidden when dosesRemaining is null', (tester) async {
      final therapy = Therapy(
        id: 1,
        drugName: 'Test Drug',
        drugDosage: '100mg',
        doseAmount: '1',
        takingFrequency: TakingFrequency.onceDaily,
        reminderTimes: ['08:00'],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        doseThreshold: 10,
        isActive: true,
        isPaused: false,
        dosesRemaining: null,
      );

      await pumpTherapyCard(tester, therapy: therapy);
      logsStreamController.add([]);
      await tester.pumpAndSettle();

      expect(find.textContaining('Rimaste:'), findsNothing);
    });
  });
}
