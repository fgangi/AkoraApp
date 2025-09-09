// test/therapy_duration_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_duration_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('TherapyDurationScreen', () {
    late MockGoRouter mockGoRouter;
    late MockNavigatorObserver mockNavigatorObserver;

    // fake data
    TherapySetupData createInitialData() {
      final drug = Drug(
        id: '1', name: 'Test Drug', dosage: '100mg', activeIngredient: '',
        quantityDescription: '', form: DrugForm.tablet,
      );
      return TherapySetupData(
        currentDrug: drug,
        selectedFrequency: TakingFrequency.onceDaily,
        reminderTimes: ['08:00'],
        startDate: DateTime(2024, 8, 21),
        endDate: DateTime(2024, 8, 28),
        doseThreshold: 10,
        doseAmount: '1',
      );
    }

    // Helper to build the screen
    Future<void> pumpScreen(WidgetTester tester, {required TherapySetupData data}) async {
      final router = GoRouter(
        initialLocation: '/',
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TherapyDurationScreen(initialData: data),
          ),
          GoRoute(
            path: '/${AppRouter.doseAndExpiryRouteName}',
            name: AppRouter.doseAndExpiryRouteName,
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );
      await tester.pumpWidget(
        CupertinoApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();
    }

    setUp(() {
      mockGoRouter = MockGoRouter();
      mockNavigatorObserver = MockNavigatorObserver();
    });

    // --- TEST CASE 1: UI Verification ---
    testWidgets('should display start and end dates from initialData', (tester) async {
      // Arrange
      final initialData = createInitialData();
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      // Check that the formatted dates are displayed on the buttons.
      expect(find.text('21 Agosto 2024'), findsOneWidget); // Start Date
      expect(find.text('28 Agosto 2024'), findsOneWidget); // End Date
    });

    // --- TEST CASE 2: Date Pickers ---
    testWidgets('tapping start and end date buttons should show date pickers', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Act & Assert for Start Date
      await tester.tap(find.text('21 Agosto 2024'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      // Close the picker to reset the state for the next action.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsNothing);

      // Act & Assert for End Date
      await tester.tap(find.text('28 Agosto 2024'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
    });

    // --- TEST CASE 3: Navigation (Avanti) ---
    testWidgets('tapping Avanti button navigates to dose and expiry screen', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Act
      await tester.tap(find.text('Avanti'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TherapyDurationScreen), findsNothing);
    });

    // --- TEST CASE 4: Navigation (Back Button) ---
    testWidgets('tapping orario button pops the screen', (tester) async {
      // Arrange
      final initialData = createInitialData();
      
      await tester.pumpWidget(
        CupertinoApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const Text('Previous Page')),
              GoRoute(
                path: '/duration',
                builder: (context, state) => TherapyDurationScreen(
                  initialData: state.extra as TherapySetupData,
                ),
              ),
            ],
          ),
        ),
      );
      
      final router = GoRouter.of(tester.element(find.text('Previous Page')));
      router.push('/duration', extra: initialData);
      await tester.pumpAndSettle();

      expect(find.byType(TherapyDurationScreen), findsOneWidget);

      // Act
      // Find the back button and tap it.
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle(); 

      // Assert
      // 1. The screen we were on should now be gone.
      expect(find.byType(TherapyDurationScreen), findsNothing);

      // 2. The screen that was "behind" it should now be visible.
      expect(find.text('Previous Page'), findsOneWidget);
    });

    // --- TEST CASE 5: Date Validation ---
    testWidgets('end date cannot be before start date', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Act - Try to set end date before start date
      await tester.tap(find.text('28 Agosto 2024')); // End date button
      await tester.pumpAndSettle();
      
      // The date picker should be visible
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      
      // Select a date before the start date
      final picker = tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
      expect(picker.minimumDate, equals(initialData.startDate));
    });

    // --- TEST CASE 6: Date Update Logic ---
    testWidgets('updating start date adjusts end date if necessary', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.startDate = DateTime(2024, 8, 21);
      initialData.endDate = DateTime(2024, 8, 25); // 4 days later
      await pumpScreen(tester, data: initialData);

      // Act - Change start date to be after end date
      await tester.tap(find.text('21 Agosto 2024')); // Start date button
      await tester.pumpAndSettle();
      
      // Simulate picking a date after the current end date
      final newStartDate = DateTime(2024, 8, 30);
      final picker = tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
      picker.onDateTimeChanged(newStartDate);
      await tester.pumpAndSettle();

      // Close the picker
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Assert - End date should be adjusted to be after start date
      expect(find.text('30 Agosto 2024'), findsOneWidget); // New start date
      expect(find.text('31 Agosto 2024'), findsOneWidget); // Auto-adjusted end date
    });

    // --- TEST CASE 7: Single Edit Mode ---
    testWidgets('in single edit mode, shows Conferma button instead of Avanti', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.isSingleEditMode = true;
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      expect(find.text('Conferma'), findsOneWidget);
      expect(find.text('Avanti'), findsNothing);
    });

    testWidgets('in single edit mode, navigation bar shows Riepilogo as previous page', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.isSingleEditMode = true;
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert - Check that the navigation bar shows the correct back title
      final navigationBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
      expect(navigationBar.previousPageTitle, equals('Riepilogo'));
    });

    testWidgets('in single edit mode, tapping Conferma pops with updated data', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.isSingleEditMode = true;
      
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Text('Summary Page'),
          ),
          GoRoute(
            path: '/duration',
            builder: (context, state) => TherapyDurationScreen(
              initialData: state.extra as TherapySetupData,
            ),
          ),
        ],
      );

      await tester.pumpWidget(CupertinoApp.router(routerConfig: router));
      
      // Navigate to duration screen
      final context = tester.element(find.text('Summary Page'));
      GoRouter.of(context).push('/duration', extra: initialData);
      await tester.pumpAndSettle();

      // Act - Tap Conferma
      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      // Assert - Should return to summary page
      expect(find.text('Summary Page'), findsOneWidget);
      expect(find.byType(TherapyDurationScreen), findsNothing);
    });

    // --- TEST CASE 8: Normal Mode Navigation ---
    testWidgets('in normal mode, shows Avanti button and navigates forward', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.isSingleEditMode = false;
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      expect(find.text('Avanti'), findsOneWidget);
      expect(find.text('Conferma'), findsNothing);
    });

    testWidgets('in normal mode, navigation bar shows Orario as previous page', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.isSingleEditMode = false;
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert - Check that the navigation bar shows the correct back title
      final navigationBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
      expect(navigationBar.previousPageTitle, equals('Orario'));
    });

    // --- TEST CASE 9: Date Picker Interaction ---
    testWidgets('date picker shows correct initial date', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Act - Open start date picker
      await tester.tap(find.text('21 Agosto 2024'));
      await tester.pumpAndSettle();

      // Assert
      final picker = tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
      expect(picker.initialDateTime, equals(initialData.startDate));
    });

    testWidgets('can change both start and end dates', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Act - Change start date
      await tester.tap(find.text('21 Agosto 2024'));
      await tester.pumpAndSettle();
      
      final newStartDate = DateTime(2024, 9, 1);
      final startPicker = tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
      startPicker.onDateTimeChanged(newStartDate);
      await tester.pumpAndSettle();

      // Close start date picker
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Change end date
      await tester.tap(find.text('2 Settembre 2024')); // Auto-adjusted end date
      await tester.pumpAndSettle();
      
      final newEndDate = DateTime(2024, 9, 15);
      final endPicker = tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
      endPicker.onDateTimeChanged(newEndDate);
      await tester.pumpAndSettle();

      // Close end date picker
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Assert - Both dates should be updated
      expect(find.text('1 Settembre 2024'), findsOneWidget);
      expect(find.text('15 Settembre 2024'), findsOneWidget);
    });

    // --- TEST CASE 10: Month Name Helper ---
    testWidgets('month names are correctly formatted in dates', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.startDate = DateTime(2024, 1, 15);
      initialData.endDate = DateTime(2024, 12, 25);
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert - Check that Italian month names are displayed
      expect(find.text('15 Gennaio 2024'), findsOneWidget);
      expect(find.text('25 Dicembre 2024'), findsOneWidget);
    });

    // --- TEST CASE 11: UI Layout and Styling ---
    testWidgets('displays drug name in navigation bar', (tester) async {
      // Arrange
      final initialData = createInitialData();
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      final navigationBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
      expect((navigationBar.middle as Text).data, equals(initialData.currentDrug.name));
    });

    testWidgets('displays correct section headers', (tester) async {
      // Arrange
      final initialData = createInitialData();
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      expect(find.text('IMPOSTA LA DURATA DELLA TUA TERAPIA'), findsOneWidget);
      expect(find.text('INIZIO TERAPIA'), findsOneWidget);
      expect(find.text('FINE TERAPIA'), findsOneWidget);
    });

    testWidgets('date buttons have correct styling', (tester) async {
      // Arrange
      final initialData = createInitialData();
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      final dateButtons = tester.widgetList<CupertinoButton>(
        find.byWidgetPredicate((widget) => 
          widget is CupertinoButton && 
          widget.color != null && 
          widget.padding == const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        )
      );
      expect(dateButtons.length, equals(2)); // Start and end date buttons
    });

    // --- TEST CASE 12: Edge Cases ---
    testWidgets('handles same start and end date', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.endDate = initialData.startDate; // Same date
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert - Should display the same date for both
      expect(find.text('21 Agosto 2024'), findsNWidgets(2));
    });

    testWidgets('handles very long drug name', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.currentDrug = Drug(
        id: '1', 
        name: 'Very Long Drug Name That Might Overflow The Navigation Bar Title Space', 
        dosage: '100mg', 
        activeIngredient: '', 
        quantityDescription: '', 
        form: DrugForm.tablet,
      );
      
      // Act & Assert - Should not throw
      await pumpScreen(tester, data: initialData);
      expect(find.textContaining('Very Long Drug Name'), findsOneWidget);
    });
  });
}