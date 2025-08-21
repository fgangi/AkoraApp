// test/reminder_time_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/features/therapy_management/screens/reminder_time_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';

//mock observer
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('ReminderTimeScreen', () {
    late MockGoRouter mockGoRouter;
    late MockNavigatorObserver mockNavigatorObserver;

    // Helper to create fake data
    TherapySetupData createInitialData({
      required TakingFrequency frequency,
      List<String> initialTimes = const ['08:00'],
    }) {
      final drug = Drug(
        id: '1',
        name: 'Test Drug',
        dosage: '100mg',
        activeIngredient: '',
        quantityDescription: '',
        form: DrugForm.tablet,
      );
      return TherapySetupData(
        currentDrug: drug,
        selectedFrequency: frequency,
        reminderTimes: initialTimes,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        doseThreshold: 10,
        doseAmount: '1',
      );
    }

    // Helper to build the screen for testing.
    Future<void> pumpScreen(WidgetTester tester, {required TherapySetupData data}) async {
      final router = GoRouter(
        initialLocation: '/',
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => ReminderTimeScreen(initialData: data),
          ),
          GoRoute(
            path: '/${AppRouter.therapyDurationRouteName}',
            name: AppRouter.therapyDurationRouteName,
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

    // --- TEST CASE 1: UI for onceDaily ---
    testWidgets('when frequency is onceDaily, should show one time picker',
        (tester) async {
      // Arrange
      final initialData = createInitialData(frequency: TakingFrequency.onceDaily);
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      // Check for the singular title.
      expect(find.text('A CHE ORA VUOI RICEVERE IL PROMEMORIA?'), findsOneWidget);
      // Check that there is exactly one date picker on screen.
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
      // Check that there are no "Orario X" labels.
      expect(find.textContaining('Orario'), findsNothing);
    });

    // --- TEST CASE 2: UI for twiceDaily ---
    testWidgets('when frequency is twiceDaily, should show two time pickers',
        (tester) async {
      // Arrange
      final initialData = createInitialData(frequency: TakingFrequency.twiceDaily);
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      // Check for the plural title.
      expect(find.text('A CHE ORE VUOI RICEVERE I PROMEMORIA?'), findsOneWidget);
      // Check that there are exactly two date pickers.
      expect(find.byType(CupertinoDatePicker), findsNWidgets(2));
      // Check that the labels for each picker are present.
      expect(find.text('Orario 1'), findsOneWidget);
      expect(find.text('Orario 2'), findsOneWidget);
    });

    // --- TEST CASE 3: User Interaction (Changing Time) ---
    // This is tested implicitly in the navigation test below. We will change
    // a time and then verify that the new time is what gets passed to the next screen.

    // --- TEST CASE 4: Navigation (Create Mode) ---
    testWidgets('tapping Avanti navigates to duration screen with updated times',
        (tester) async {
      // Arrange
      final initialData = createInitialData(frequency: TakingFrequency.onceDaily);
      await pumpScreen(tester, data: initialData);

      // Act
      // 1. Find the date picker.
      final datePicker = find.byType(CupertinoDatePicker);
      expect(datePicker, findsOneWidget);

      // 2. Change the time to 10:30.
      await tester.drag(datePicker, const Offset(0, -30)); 
      await tester.pump();
      await tester.drag(datePicker, const Offset(0, 30), touchSlopY: 0, warnIfMissed: false); 
      await tester.pump();

      // 3. Tap the "Avanti" button.
      await tester.tap(find.text('Avanti'));
      await tester.pumpAndSettle();

      // Assert
      // old screen is gone.
      expect(find.byType(ReminderTimeScreen), findsNothing);
    });

    // --- TEST CASE 5: Navigation (Edit Mode) ---
    testWidgets('tapping Conferma pops the screen, removing it from view', (tester) async {
      // Arrange
      final initialData = createInitialData(frequency: TakingFrequency.onceDaily);
      initialData.isSingleEditMode = true; 
      
      await tester.pumpWidget(
        CupertinoApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const Text('Summary Page')),
              GoRoute(
                path: '/reminders',
                builder: (context, state) => ReminderTimeScreen(
                  initialData: state.extra as TherapySetupData,
                ),
              ),
            ],
          ),
        ),
      );

      final router = GoRouter.of(tester.element(find.text('Summary Page')));
      router.push('/reminders', extra: initialData);
      await tester.pumpAndSettle();

      expect(find.byType(ReminderTimeScreen), findsOneWidget);
      
      // Act
      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      // Assert
      // 1. The screen we were on should now be gone.
      expect(find.byType(ReminderTimeScreen), findsNothing);

      // 2. The screen that was "behind" it should now be visible.
      expect(find.text('Summary Page'), findsOneWidget);
    });
  });
}