// test/therapy_summary_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_summary_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

// mocks
import 'home_screen_test.mocks.dart';

void main() {
  group('TherapySummaryScreen', () {
    late MockAppDatabase mockDatabase;
    late MockNotificationService mockNotificationService;
    late MockGoRouter mockGoRouter;

    // therapy object
    Therapy createRealTherapy({int? dosesRemaining, DateTime? expiryDate}) {
      return Therapy(
        id: 1,
        drugName: 'Real Test Therapy',
        drugDosage: '100mg',
        doseAmount: '1',
        takingFrequency: TakingFrequency.onceDaily,
        reminderTimes: ['08:00'],
        //repeatAfter10Min: false,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        doseThreshold: 10,
        isActive: true,
        isPaused: false,
        dosesRemaining: dosesRemaining,
        expiryDate: expiryDate,
      );
    }

    // Helper to create the data model for the screen
    TherapySetupData createInitialData({
      Therapy? initialTherapy,
      TakingFrequency frequency = TakingFrequency.onceDaily,
      DateTime? expiryDate = null,
      int? initialDoses,
    }) {
      final drug = Drug(
        id: '1', name: 'Test Drug', dosage: '100mg', activeIngredient: '',
        quantityDescription: '', form: DrugForm.tablet,
      );
      return TherapySetupData(
        currentDrug: drug, selectedFrequency: frequency, reminderTimes: ['09:00'],
        startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 7)),
        doseThreshold: 10, doseAmount: '1', initialTherapy: initialTherapy,
        expiryDate: expiryDate, initialDoses: initialDoses,
      );
    }

    // Helper to build the screen
    Future<void> pumpScreen(WidgetTester tester, {required TherapySetupData data}) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: TherapySummaryScreen(
              setupData: data,
              database: mockDatabase,
              notificationService: mockNotificationService,
            ),
          ),
        ),
      );
    }

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockNotificationService = MockNotificationService();
      mockGoRouter = MockGoRouter();

      // --- STUB ALL SERVICE CALLS ---
      when(mockDatabase.createTherapy(any)).thenAnswer((_) async => 1);
      when(mockDatabase.updateTherapy(any)).thenAnswer((_) async => 1);
      when(mockDatabase.getTherapyById(any)).thenAnswer((_) async => createRealTherapy());
      when(mockNotificationService.scheduleNotificationForTherapy(any)).thenAnswer((_) async {});
      when(mockNotificationService.scheduleExpiryNotification(any)).thenAnswer((_) async {});
      when(mockNotificationService.cancelTherapyNotifications(any)).thenAnswer((_) async {});
      when(mockNotificationService.triggerLowStockNotification(
          therapyId: anyNamed('therapyId'),
          drugName: anyNamed('drugName'),
          remainingDoses: anyNamed('remainingDoses')))
          .thenAnswer((_) async {});
      when(mockNotificationService.cancelLowStockNotification(any)).thenAnswer((_) async {});
      when(mockGoRouter.goNamed(any)).thenReturn(null);
      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra'))).thenAnswer((_) async => null);
    });

    // --- TEST CASE 1: UI Verification ---
    testWidgets('should display summary details from the data model', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.startDate = DateTime(2024, 2, 15);
      initialData.endDate = DateTime(2024, 2, 25);
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      expect(find.text('Test Drug 100mg'), findsOneWidget);
      expect(find.text('Ogni giorno alle 09:00'), findsOneWidget);
      expect(find.text('Dal 15/02/2024 al 25/02/2024'), findsOneWidget);
      expect(find.text('Avviso a 10 dosi rimanenti'), findsOneWidget);
    });

    // --- TEST CASE 2: Save and Navigate ---
    testWidgets('tapping "SALVA E CONFERMA" in create mode calls createTherapy and navigates',
        (tester) async {
      // fake the platform to avoid the Android permission check.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      
      // Arrange
      final initialData = createInitialData(initialTherapy: null);
      await pumpScreen(tester, data: initialData);

      // Act
      await tester.tap(find.text('SALVA E CONFERMA'));
      await tester.pump(const Duration(milliseconds: 100)); 
      await tester.pumpAndSettle(); 

      // Assert
      verify(mockDatabase.createTherapy(any)).called(1);
      verify(mockNotificationService.scheduleNotificationForTherapy(any)).called(1);
      verify(mockGoRouter.goNamed(AppRouter.homeRouteName)).called(1);
      verifyNever(mockDatabase.updateTherapy(any));
      
      // Cleanup
      debugDefaultTargetPlatformOverride = null;
    });

    // --- TEST CASE 3: Navigate Edit Mode ---
    testWidgets('tapping "SALVA E CONFERMA" in edit mode calls updateTherapy and navigates',
        (tester) async {
      // Fake the platform to avoid the Android permission check.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      // Arrange
      final initialData = createInitialData(initialTherapy: createRealTherapy());
      await pumpScreen(tester, data: initialData);

      // Act
      await tester.tap(find.text('SALVA E CONFERMA'));
      await tester.pump(const Duration(milliseconds: 100)); 
      await tester.pumpAndSettle();

      // Assert
      verify(mockDatabase.updateTherapy(any)).called(1);
      verify(mockNotificationService.cancelTherapyNotifications(any)).called(1);
      verify(mockNotificationService.scheduleNotificationForTherapy(any)).called(1);
      verify(mockGoRouter.goNamed(AppRouter.homeRouteName)).called(1);
      verifyNever(mockDatabase.createTherapy(any));

      // Cleanup
      debugDefaultTargetPlatformOverride = null;
    });

    // --- TEST CASE 4: Tapping Edit Button (Pencil Icon) ---
    testWidgets('tapping the frequency pencil icon navigates to the correct screen in edit mode',
        (tester) async {
      // Arrange
      final initialData = createInitialData();
      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
          .thenAnswer((_) async => null);

      await pumpScreen(tester, data: initialData);

      // Act
      final frequencyRow = find.ancestor(
        of: find.textContaining('Ogni giorno alle'), 
        matching: find.byType(Row),              
      );
      
      final pencilIcon = find.descendant(
        of: frequencyRow,
        matching: find.byIcon(CupertinoIcons.pencil),
      );
      
      expect(pencilIcon, findsOneWidget); 

      // Tap the icon.
      await tester.tap(pencilIcon);
      await tester.pumpAndSettle();

      // Assert
      final captured = verify(mockGoRouter.pushNamed(
        AppRouter.therapyFrequencyRouteName, 
        extra: captureAnyNamed('extra'),
      )).captured;

      final capturedData = captured.first as TherapySetupData;

      expect(capturedData.isSingleEditMode, isTrue);
    });

    testWidgets('tapping the duration pencil icon navigates correctly', (tester) async {
      // Arrange
      final initialData = createInitialData();
      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
          .thenAnswer((_) async => null);
      await pumpScreen(tester, data: initialData);

      // Act
      final durationRow = find.ancestor(
        of: find.textContaining('Dal'), 
        matching: find.byType(Row),
      );
      final pencilIcon = find.descendant(
        of: durationRow,
        matching: find.byIcon(CupertinoIcons.pencil),
      );
      await tester.tap(pencilIcon);
      await tester.pumpAndSettle();

      // Assert
      final captured = verify(mockGoRouter.pushNamed(
        AppRouter.therapyDurationRouteName, 
        extra: captureAnyNamed('extra'),
      )).captured;
      final capturedData = captured.first as TherapySetupData;
      expect(capturedData.isSingleEditMode, isTrue);
    });

    testWidgets('tapping the dose/expiry pencil icon navigates correctly', (tester) async {
      // Arrange 
      final initialData = createInitialData();
      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
          .thenAnswer((_) async => null);
      await pumpScreen(tester, data: initialData);

      // Act 
      final doseRow = find.ancestor(
        of: find.textContaining('Avviso a'),
        matching: find.byType(Row),
      );
      final pencilIcon = find.descendant(
        of: doseRow,
        matching: find.byIcon(CupertinoIcons.pencil),
      );
      await tester.tap(pencilIcon);
      await tester.pumpAndSettle();

      // Assert 
      final captured = verify(mockGoRouter.pushNamed(
        AppRouter.doseAndExpiryRouteName, 
        extra: captureAnyNamed('extra'),
      )).captured;
      final capturedData = captured.first as TherapySetupData;
      expect(capturedData.isSingleEditMode, isTrue);
    });

        // --- Save Button Logic Tests ---
    group('Save and Confirm Logic', () {
      // Setup the mock handler for the permission plugin
      setUp(() {
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'requestPermissions') {
              return {
                Permission.scheduleExactAlarm.value: PermissionStatus.granted.index
              };
            }
            if (methodCall.method == 'checkPermissionStatus') {
              return PermissionStatus.granted.index;
            }
            return null;
          },
        );
      });

      tearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'), null);
      });

      testWidgets('low stock notification is triggered if below threshold', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final initialData = createInitialData(initialDoses: 5); // 5 is less than threshold of 10

        final expectedTherapyAfterSave = Therapy(
          id: 1, drugName: 'Test Drug', drugDosage: '100mg', doseAmount: '1',
          takingFrequency: TakingFrequency.onceDaily, reminderTimes: ['09:00'],
          startDate: initialData.startDate, endDate: initialData.endDate, doseThreshold: 10,
          isActive: true, isPaused: false,
          dosesRemaining: 5,
        );

        when(mockDatabase.getTherapyById(any)).thenAnswer((_) async => expectedTherapyAfterSave);

        await pumpScreen(tester, data: initialData);
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        verify(mockNotificationService.triggerLowStockNotification(
          therapyId: 1,
          drugName: 'Test Drug',
          remainingDoses: 5,
        )).called(1);

        debugDefaultTargetPlatformOverride = null;
      });
      
      testWidgets('cancels low stock notification if above threshold', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        // Start with a therapy that is LOW on stock.
        final therapy = createRealTherapy(dosesRemaining: 5);
        final initialData = createInitialData(initialTherapy: therapy, initialDoses: 20); // User refills to 20
        await pumpScreen(tester, data: initialData);

        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        verify(mockNotificationService.cancelLowStockNotification(any)).called(1);
        verifyNever(mockNotificationService.triggerLowStockNotification(
          therapyId: anyNamed('therapyId'), drugName: anyNamed('drugName'), remainingDoses: anyNamed('remainingDoses')));
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('shows loading indicator while saving', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final initialData = createInitialData();
        final saveCompleter = Completer<int>();

        when(mockDatabase.createTherapy(any)).thenAnswer((_) => saveCompleter.future);
        await pumpScreen(tester, data: initialData);
        await tester.tap(find.text('SALVA E CONFERMA'));        
        await tester.pump(); 

        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        // The button text should be gone
        expect(find.text('SALVA E CONFERMA'), findsNothing);
        saveCompleter.complete(1);
        
        await tester.pumpAndSettle();
        // The loading indicator should now be gone.
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
        // And the navigation should have happened.
        verify(mockGoRouter.goNamed(AppRouter.homeRouteName)).called(1);
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('in create mode, Annulla button is visible and navigates home without saving', (tester) async {
      // Arrange
      // We are in create mode, so initialTherapy is null
      final initialData = createInitialData(initialTherapy: null);
      await pumpScreen(tester, data: initialData);

      // Act
      // Find the "Annulla" button and tap it.
      final annullaButton = find.text('Annulla');
      expect(annullaButton, findsOneWidget);
      await tester.tap(annullaButton);
      await tester.pumpAndSettle();

      // Assert
      // Verify it navigated home and DID NOT call any save/update methods.
      verify(mockGoRouter.goNamed(AppRouter.homeRouteName)).called(1);
      verifyNever(mockDatabase.createTherapy(any));
      verifyNever(mockDatabase.updateTherapy(any));
    });

    testWidgets('in edit mode, a back button is visible and pops the route', (tester) async {
      // Arrange
      final therapy = createRealTherapy();
      // We are in a full edit flow, not a single-jump edit
      final initialData = TherapySetupData.fromTherapy(therapy)..isSingleEditMode = false;

      when(mockGoRouter.canPop()).thenReturn(true);
      await pumpScreen(tester, data: initialData);

      // --- THE FIX IS HERE ---
      // Instead of finding by type, we find the widget that contains the "Indietro" text.
      final backButton = find.widgetWithText(CupertinoButton, 'Indietro');
      
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Assert
      verify(mockGoRouter.pop()).called(1);
      verifyNever(mockGoRouter.goNamed(any));
    });

    testWidgets('calls scheduleExpiryNotification when an expiry date is provided', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      
      // Arrange
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      final initialData = createInitialData(expiryDate: expiryDate);
      
      await pumpScreen(tester, data: initialData);

      // Act
      await tester.tap(find.text('SALVA E CONFERMA'));
      await tester.pumpAndSettle();

      // Assert
      // Verify both the main and expiry notification methods were called.
      verify(mockNotificationService.scheduleNotificationForTherapy(any)).called(1);
      verify(mockNotificationService.scheduleExpiryNotification(any)).called(1);
      
      debugDefaultTargetPlatformOverride = null;
    });

      /*testWidgets('shows permission dialog if permission is denied on Android', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        // Override the mock handler for THIS test to simulate a DENIED permission
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'), (MethodCall methodCall) async {
            if (methodCall.method == 'requestPermissions') {
              return { (Permission.scheduleExactAlarm.value): PermissionStatus.denied.index};
            }
            if (methodCall.method == 'checkPermissionStatus') {
              return PermissionStatus.denied.index;
            }
            return null;
          });

        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        // Assert: The dialog should appear, and no database/navigation calls were made
        expect(find.text('Permesso'), findsOneWidget);
        verifyNever(mockDatabase.createTherapy(any));
        verifyNever(mockGoRouter.goNamed(any));
        
        debugDefaultTargetPlatformOverride = null;
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter.baseflow.com/permissions/methods'), null);
      });*/
    });
  });
}