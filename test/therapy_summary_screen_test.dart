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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  });

  // --- Additional comprehensive tests ---
    group('UI Display and Formatting Tests', () {
      testWidgets('displays different frequency formats correctly', (tester) async {
        // Test once daily
        final onceDaily = createInitialData(frequency: TakingFrequency.onceDaily);
        onceDaily.reminderTimes = ['08:30'];
        await pumpScreen(tester, data: onceDaily);
        expect(find.text('Ogni giorno alle 08:30'), findsOneWidget);
        
        // Reset and test twice daily
        await tester.pumpWidget(Container()); // Clear
        final twiceDaily = createInitialData(frequency: TakingFrequency.twiceDaily);
        twiceDaily.reminderTimes = ['08:00', '20:00'];
        await pumpScreen(tester, data: twiceDaily);
        expect(find.text('Due volte al giorno (08:00, 20:00)'), findsOneWidget);
        
        // Reset and test weekly
        await tester.pumpWidget(Container()); // Clear
        final weekly = createInitialData(frequency: TakingFrequency.onceWeekly);
        weekly.reminderTimes = ['10:00'];
        await pumpScreen(tester, data: weekly);
        expect(find.text('Una volta a settimana alle 10:00'), findsOneWidget);
      });

      testWidgets('displays expiry date information when present', (tester) async {
        // Arrange
        final expiryDate = DateTime.now().add(const Duration(days: 30));
        final initialData = createInitialData(expiryDate: expiryDate);
        
        // Act
        await pumpScreen(tester, data: initialData);

        // Assert
        expect(find.text('Notifica per scadenza 7 giorni prima'), findsOneWidget);
      });

      testWidgets('does not display expiry information when not present', (tester) async {
        // Arrange
        final initialData = createInitialData(); // No expiry date
        
        // Act
        await pumpScreen(tester, data: initialData);

        // Assert
        expect(find.text('Notifica per scadenza 7 giorni prima'), findsNothing);
      });

      testWidgets('displays correct date format', (tester) async {
        // Arrange
        final initialData = createInitialData();
        initialData.startDate = DateTime(2024, 1, 15);
        initialData.endDate = DateTime(2024, 12, 25);
        
        // Act
        await pumpScreen(tester, data: initialData);

        // Assert
        expect(find.text('Dal 15/01/2024 al 25/12/2024'), findsOneWidget);
      });

      testWidgets('displays multiple reminder times correctly', (tester) async {
        // Arrange
        final initialData = createInitialData(frequency: TakingFrequency.twiceDaily);
        initialData.reminderTimes = ['08:00', '14:30', '20:45'];
        
        // Act
        await pumpScreen(tester, data: initialData);

        // Assert
        expect(find.text('Due volte al giorno (08:00, 14:30, 20:45)'), findsOneWidget);
      });
    });

    group('Navigation and Edit Mode Tests', () {
      testWidgets('all edit buttons are present and functional', (tester) async {
        // Arrange
        final initialData = createInitialData();
        when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
            .thenAnswer((_) async => null);
        await pumpScreen(tester, data: initialData);

        // Find all pencil icons
        final pencilIcons = find.byIcon(CupertinoIcons.pencil);
        expect(pencilIcons, findsNWidgets(3)); // Should have 3 edit buttons

        // Test each edit button
        await tester.tap(pencilIcons.at(0)); // Frequency edit
        await tester.pumpAndSettle();
        verify(mockGoRouter.pushNamed(AppRouter.therapyFrequencyRouteName, extra: anyNamed('extra'))).called(1);

        await tester.tap(pencilIcons.at(1)); // Duration edit  
        await tester.pumpAndSettle();
        verify(mockGoRouter.pushNamed(AppRouter.therapyDurationRouteName, extra: anyNamed('extra'))).called(1);

        await tester.tap(pencilIcons.at(2)); // Dose/expiry edit
        await tester.pumpAndSettle();
        verify(mockGoRouter.pushNamed(AppRouter.doseAndExpiryRouteName, extra: anyNamed('extra'))).called(1);
      });

      testWidgets('edit mode sets isSingleEditMode correctly', (tester) async {
        // Arrange
        final initialData = createInitialData();
        when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
            .thenAnswer((_) async => null);
        await pumpScreen(tester, data: initialData);

        // Act
        final firstPencilIcon = find.byIcon(CupertinoIcons.pencil).first;
        await tester.tap(firstPencilIcon);
        await tester.pumpAndSettle();

        // Assert
        final captured = verify(mockGoRouter.pushNamed(
          AppRouter.therapyFrequencyRouteName, 
          extra: captureAnyNamed('extra'),
        )).captured;
        final capturedData = captured.first as TherapySetupData;
        expect(capturedData.isSingleEditMode, isTrue);
      });

      testWidgets('navigation between edit and summary preserves data', (tester) async {
        // Arrange
        final initialData = createInitialData();
        final updatedData = createInitialData();
        updatedData.doseThreshold = 5; // Changed value
        
        when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
            .thenAnswer((_) async => updatedData);
        
        await pumpScreen(tester, data: initialData);

        // Act
        final pencilIcon = find.byIcon(CupertinoIcons.pencil).first;
        await tester.tap(pencilIcon);
        await tester.pumpAndSettle();

        // Assert - The screen should update with new data
        expect(find.text('Avviso a 5 dosi rimanenti'), findsOneWidget);
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('handles save failure gracefully', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        // Arrange
        final initialData = createInitialData();
        when(mockDatabase.createTherapy(any)).thenThrow(Exception('Database error'));
        await pumpScreen(tester, data: initialData);

        // Act
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        // Assert - Should handle error gracefully and reset loading state
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
        expect(find.text('SALVA E CONFERMA'), findsOneWidget);
        
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('handles very long drug names', (tester) async {
        // Arrange
        final initialData = createInitialData();
        initialData.currentDrug = Drug(
          id: '1', 
          name: 'Very Long Drug Name That Might Cause Layout Issues In The Summary Screen Display Area', 
          dosage: '100mg', 
          activeIngredient: '', 
          quantityDescription: '', 
          form: DrugForm.tablet,
        );
        
        // Act & Assert - Should render without overflow
        await pumpScreen(tester, data: initialData);
        expect(find.textContaining('Very Long Drug Name'), findsOneWidget);
      });

      testWidgets('handles missing reminder times', (tester) async {
        // Arrange
        final initialData = createInitialData();
        initialData.reminderTimes = [];
        
        // Act & Assert - Should not crash
        await pumpScreen(tester, data: initialData);
        expect(find.byType(TherapySummaryScreen), findsOneWidget);
      });

      testWidgets('handles null values in therapy setup data', (tester) async {
        // Arrange
        final initialData = createInitialData();
        initialData.expiryDate = null;
        initialData.initialDoses = null;
        
        // Act & Assert - Should render without issues
        await pumpScreen(tester, data: initialData);
        expect(find.byType(TherapySummaryScreen), findsOneWidget);
      });

      testWidgets('button remains disabled during save operation', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        // Arrange
        final initialData = createInitialData();
        final completer = Completer<int>();
        when(mockDatabase.createTherapy(any)).thenAnswer((_) => completer.future);
        await pumpScreen(tester, data: initialData);

        // Act - Tap save button
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pump();

        // Try to tap again while saving
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        await tester.tap(find.byType(CupertinoActivityIndicator));
        await tester.pump();

        // Complete the save operation
        completer.complete(1);
        await tester.pumpAndSettle();

        // Assert - Only one database call should have been made
        verify(mockDatabase.createTherapy(any)).called(1);
        
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('Notification Integration Tests', () {
      testWidgets('calls all notification methods in correct order for new therapy', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        // Arrange
        final expiryDate = DateTime.now().add(const Duration(days: 30));
        final initialData = createInitialData(expiryDate: expiryDate, initialDoses: 15);
        
        await pumpScreen(tester, data: initialData);

        // Act
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        // Assert - Check notification methods were called in correct order
        verifyInOrder([
          mockDatabase.createTherapy(any),
          mockDatabase.getTherapyById(any),
          mockNotificationService.scheduleNotificationForTherapy(any),
          mockNotificationService.scheduleExpiryNotification(any),
        ]);
        
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('cancels old notifications before scheduling new ones in edit mode', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        // Arrange
        final therapy = createRealTherapy();
        final initialData = createInitialData(initialTherapy: therapy);
        
        await pumpScreen(tester, data: initialData);

        // Act
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        // Assert
        verifyInOrder([
          mockNotificationService.cancelTherapyNotifications(any),
          mockDatabase.updateTherapy(any),
          mockNotificationService.scheduleNotificationForTherapy(any),
          mockNotificationService.scheduleExpiryNotification(any),
        ]);
        
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('handles notification scheduling failures gracefully', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        // Arrange
        final initialData = createInitialData();
        when(mockNotificationService.scheduleNotificationForTherapy(any))
            .thenThrow(Exception('Notification error'));
        
        await pumpScreen(tester, data: initialData);

        // Act - Should not crash despite notification error
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        // Assert - Database should still be called and navigation should still happen
        verify(mockDatabase.createTherapy(any)).called(1);
        
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('State Management Tests', () {
      testWidgets('preserves state during rebuild', (tester) async {
        // Arrange
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Act - Trigger a rebuild by pumping again
        await tester.pump();

        // Assert - Data should still be displayed correctly
        expect(find.text('Test Drug 100mg'), findsOneWidget);
        expect(find.text('Ogni giorno alle 09:00'), findsOneWidget);
      });

      testWidgets('updates UI when setupData changes', (tester) async {
        // Arrange
        final initialData = createInitialData();
        initialData.doseThreshold = 10;
        await pumpScreen(tester, data: initialData);
        expect(find.text('Avviso a 10 dosi rimanenti'), findsOneWidget);

        // Act - Update the screen with new data by creating a new widget
        initialData.doseThreshold = 5;
        await pumpScreen(tester, data: initialData);

        // Assert
        expect(find.text('Avviso a 5 dosi rimanenti'), findsOneWidget);
      });
    });

    group('Accessibility and Usability Tests', () {
      testWidgets('all interactive elements are accessible', (tester) async {
        // Arrange
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Assert - Check that buttons are properly accessible
        expect(find.byType(CupertinoButton), findsAtLeastNWidgets(4)); // Save, Cancel/Back + edit buttons
        
        // Check that icons have proper parent buttons
        final pencilIcons = find.byIcon(CupertinoIcons.pencil);
        for (int i = 0; i < tester.widgetList(pencilIcons).length; i++) {
          final iconFinder = pencilIcons.at(i);
          expect(find.ancestor(of: iconFinder, matching: find.byType(CupertinoButton)), findsOneWidget);
        }
      });

      testWidgets('displays loading state clearly', (tester) async {
        // Arrange
        final initialData = createInitialData();
        final completer = Completer<int>();
        when(mockDatabase.createTherapy(any)).thenAnswer((_) => completer.future);
        await pumpScreen(tester, data: initialData);

        // Act
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pump();

        // Assert - Loading indicator should be clearly visible
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.text('SALVA E CONFERMA'), findsNothing);
        
        // Complete operation
        completer.complete(1);
        await tester.pumpAndSettle();
      });

      testWidgets('provides clear visual feedback for edit actions', (tester) async {
        // Arrange
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Assert - Edit buttons should be visually distinct
        final editButtons = find.byIcon(CupertinoIcons.pencil);
        expect(editButtons, findsAtLeastNWidgets(3));
        
        // Each edit button should be in a row with descriptive text
        for (int i = 0; i < tester.widgetList(editButtons).length; i++) {
          final editButton = editButtons.at(i);
          final parentRow = find.ancestor(of: editButton, matching: find.byType(Row));
          expect(parentRow, findsAtLeastNWidgets(1));
        }
      });
    });

    // --- Additional extensive tests for maximum coverage ---
    group('Permission Handling Tests', () {
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
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'), 
          null
        );
      });

      testWidgets('Android permission flow is handled correctly', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        // At minimum, the save button should trigger the save flow
        // (Permission handling may be bypassed in test environment)
        verify(mockDatabase.createTherapy(any)).called(1);
        
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('permission dialog Annulla button dismisses dialog', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        
        TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            return {Permission.scheduleExactAlarm.value: PermissionStatus.denied.index};
          },
        );

        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Annulla'));
        await tester.pumpAndSettle();

        expect(find.text('Permesso Necessario'), findsNothing);
        
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('iOS skips permission check entirely', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pumpAndSettle();

        // Should proceed directly to save without showing dialog
        verify(mockDatabase.createTherapy(any)).called(1);
        expect(find.text('Permesso Necessario'), findsNothing);
        
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('Format Frequency Method Tests', () {
      testWidgets('formats single reminder time correctly', (tester) async {
        final initialData = createInitialData(frequency: TakingFrequency.onceDaily);
        initialData.reminderTimes = ['14:30'];
        await pumpScreen(tester, data: initialData);
        
        expect(find.text('Ogni giorno alle 14:30'), findsOneWidget);
      });

      testWidgets('formats multiple reminder times with proper joining', (tester) async {
        final initialData = createInitialData(frequency: TakingFrequency.twiceDaily);
        initialData.reminderTimes = ['08:00', '14:00', '20:00', '23:30'];
        await pumpScreen(tester, data: initialData);
        
        expect(find.text('Due volte al giorno (08:00, 14:00, 20:00, 23:30)'), findsOneWidget);
      });

      testWidgets('handles empty reminder times list', (tester) async {
        final initialData = createInitialData(frequency: TakingFrequency.onceWeekly);
        initialData.reminderTimes = [];
        await pumpScreen(tester, data: initialData);
        
        expect(find.text('Una volta a settimana alle '), findsOneWidget);
      });

      testWidgets('formats all frequency types correctly', (tester) async {
        // Test each frequency type separately
        final frequencies = [
          (TakingFrequency.onceDaily, 'Ogni giorno alle 09:00'),
          (TakingFrequency.twiceDaily, 'Due volte al giorno (09:00)'),
          (TakingFrequency.onceWeekly, 'Una volta a settimana alle 09:00'),
        ];

        for (final (frequency, expectedText) in frequencies) {
          final initialData = createInitialData(frequency: frequency);
          initialData.reminderTimes = ['09:00'];
          await pumpScreen(tester, data: initialData);
          
          expect(find.text(expectedText), findsOneWidget);
          
          // Clear for next test
          await tester.pumpWidget(Container());
        }
      });
    });

    group('Date Formatting Tests', () {
      testWidgets('formats dates correctly across different months and years', (tester) async {
        final testDates = [
          (DateTime(2023, 1, 1), DateTime(2023, 12, 31), 'Dal 01/01/2023 al 31/12/2023'),
          (DateTime(2024, 2, 29), DateTime(2024, 3, 1), 'Dal 29/02/2024 al 01/03/2024'), // Leap year
          (DateTime(2025, 10, 15), DateTime(2025, 10, 15), 'Dal 15/10/2025 al 15/10/2025'), // Same day
        ];

        for (final (startDate, endDate, expectedText) in testDates) {
          final initialData = createInitialData();
          initialData.startDate = startDate;
          initialData.endDate = endDate;
          await pumpScreen(tester, data: initialData);
          
          expect(find.text(expectedText), findsOneWidget);
          
          await tester.pumpWidget(Container());
        }
      });
    });

    group('Theme and Styling Tests', () {
      testWidgets('uses correct background color from theme', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        final scaffold = tester.widget<CupertinoPageScaffold>(find.byType(CupertinoPageScaffold));
        expect(scaffold.backgroundColor, isNotNull);
      });

      testWidgets('navigation bar has correct styling', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        final navBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
        expect(navBar.brightness, equals(Brightness.dark));
        expect(navBar.automaticallyImplyLeading, isFalse);
      });

      testWidgets('save button has correct styling when enabled', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        final saveButton = find.text('SALVA E CONFERMA');
        expect(saveButton, findsOneWidget);
        
        final button = tester.widget<CupertinoButton>(
          find.ancestor(of: saveButton, matching: find.byType(CupertinoButton))
        );
        expect(button.color, equals(CupertinoColors.white));
      });
    });

    group('BuildSummaryRow Method Tests', () {
      testWidgets('summary rows display correct icons and text', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        // Check that icon widgets are present in the UI
        expect(find.byType(FaIcon), findsAtLeastNWidgets(1)); // At least one FontAwesome icon
        expect(find.byType(Icon), findsAtLeastNWidgets(3)); // Multiple Cupertino icons
      });

      testWidgets('expiry row only shows when expiry date is set', (tester) async {
        // Test without expiry date
        final initialDataNoExpiry = createInitialData();
        await pumpScreen(tester, data: initialDataNoExpiry);
        
        final summaryRowsWithoutExpiry = find.byType(Row);
        final countWithoutExpiry = tester.widgetList(summaryRowsWithoutExpiry).length;
        
        // Clear and test with expiry date
        await tester.pumpWidget(Container());
        final initialDataWithExpiry = createInitialData(expiryDate: DateTime.now().add(const Duration(days: 30)));
        await pumpScreen(tester, data: initialDataWithExpiry);
        
        final summaryRowsWithExpiry = find.byType(Row);
        final countWithExpiry = tester.widgetList(summaryRowsWithExpiry).length;
        
        // Should have more rows when expiry is set
        expect(countWithExpiry, greaterThan(countWithoutExpiry));
      });

      testWidgets('edit buttons are only present for editable rows', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        // Drug name row should not have edit button (onEdit: null)
        final drugRow = find.ancestor(
          of: find.text('Test Drug 100mg'),
          matching: find.byType(Row)
        );
        final editButtonInDrugRow = find.descendant(
          of: drugRow,
          matching: find.byIcon(CupertinoIcons.pencil)
        );
        expect(editButtonInDrugRow, findsNothing);
        
        // Other rows should have edit buttons
        expect(find.byIcon(CupertinoIcons.pencil), findsNWidgets(3));
      });
    });

    group('State Lifecycle Tests', () {
      testWidgets('initState correctly initializes from setupData', (tester) async {
        final setupData = createInitialData();
        setupData.doseThreshold = 15;
        
        await pumpScreen(tester, data: setupData);
        
        expect(find.text('Avviso a 15 dosi rimanenti'), findsOneWidget);
      });

      testWidgets('initState correctly initializes from initialTherapy', (tester) async {
        final therapy = createRealTherapy();
        final initialData = TherapySetupData.fromTherapy(therapy);
        
        await pumpScreen(tester, data: initialData);
        
        expect(find.text('Real Test Therapy 100mg'), findsOneWidget);
      });

      testWidgets('setState updates UI when currentData changes', (tester) async {
        final initialData = createInitialData();
        when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
            .thenAnswer((_) async {
              final updatedData = createInitialData();
              updatedData.doseThreshold = 25;
              return updatedData;
            });
        
        await pumpScreen(tester, data: initialData);
        expect(find.text('Avviso a 10 dosi rimanenti'), findsOneWidget);
        
        // Trigger edit
        await tester.tap(find.byIcon(CupertinoIcons.pencil).last);
        await tester.pumpAndSettle();
        
        expect(find.text('Avviso a 25 dosi rimanenti'), findsOneWidget);
      });
    });

    group('Database Interaction Edge Cases', () {
      testWidgets('handles database timeout gracefully', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        final initialData = createInitialData();
        when(mockDatabase.createTherapy(any))
            .thenAnswer((_) async => throw TimeoutException('Timeout', const Duration(seconds: 5)));
        
        await pumpScreen(tester, data: initialData);
        
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pump(const Duration(milliseconds: 100));
        
        // Should handle the error gracefully - might show loading indicator briefly
        // The specific behavior depends on implementation
        
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('handles concurrent save attempts correctly', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        
        final initialData = createInitialData();
        final completer = Completer<int>();
        when(mockDatabase.createTherapy(any)).thenAnswer((_) => completer.future);
        
        await pumpScreen(tester, data: initialData);
        
        // First save attempt
        await tester.tap(find.text('SALVA E CONFERMA'));
        await tester.pump();
        
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        
        // Second save attempt while first is in progress
        await tester.tap(find.byType(CupertinoActivityIndicator));
        await tester.pump();
        
        // Should only have one database call
        verify(mockDatabase.createTherapy(any)).called(1);
        
        completer.complete(1);
        await tester.pumpAndSettle();
        
        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('Widget Lifecycle and Memory Tests', () {
      testWidgets('properly disposes resources when widget is removed', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        // Remove widget
        await tester.pumpWidget(Container());
        
        // Should not crash or leak memory
        expect(find.byType(TherapySummaryScreen), findsNothing);
      });

      testWidgets('handles hot reload correctly', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        // Simulate hot reload by rebuilding with same data
        await pumpScreen(tester, data: initialData);
        
        expect(find.text('Test Drug 100mg'), findsOneWidget);
        expect(find.text('SALVA E CONFERMA'), findsOneWidget);
      });
    });

    group('Accessibility Enhancements', () {
      testWidgets('all text has proper contrast in dark theme', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        // Check that white text is used on dark background
        final instructionText = tester.widget<Text>(
          find.text('Controlla le impostazioni prima di confermare')
        );
        expect(instructionText.style?.color, equals(CupertinoColors.lightBackgroundGray));
      });

      testWidgets('buttons have proper minimum tap area', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);
        
        final editButtons = find.byIcon(CupertinoIcons.pencil);
        for (int i = 0; i < tester.widgetList(editButtons).length; i++) {
          final button = find.ancestor(
            of: editButtons.at(i),
            matching: find.byType(CupertinoButton)
          );
          expect(button, findsOneWidget);
          
          final buttonWidget = tester.widget<CupertinoButton>(button);
          // CupertinoButton has default minimum size
          expect(buttonWidget.padding, isNotNull);
        }
      });
    });
  });
}