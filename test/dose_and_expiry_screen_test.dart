// test/dose_and_expiry_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/features/therapy_management/screens/dose_and_expiry_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';

// We need a mock NavigatorObserver to track navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('DoseAndExpiryScreen', () {
    // We need a mock router to test navigation calls.
    late MockGoRouter mockGoRouter;
    late MockNavigatorObserver mockNavigatorObserver;

    // fake data
    TherapySetupData createInitialData() {
      final drug = Drug(
        id: '1',
        name: 'Aspirin',
        dosage: '100mg',
        activeIngredient: 'Acetylsalicylic Acid',
        quantityDescription: '30 compresse',
        form: DrugForm.tablet,
      );

      // fake TherapySetupData
      return TherapySetupData(
        currentDrug: drug,
        doseAmount: "1",
        doseThreshold: 10,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 10)),
        reminderTimes: ['08:00'],
        selectedFrequency: TakingFrequency.onceDaily,
      );
    }

    // A helper function to build our screen with our mock objects.
    Future<void> pumpScreen(WidgetTester tester, {required TherapySetupData data}) async {
      final router = GoRouter(
        initialLocation: '/',
        observers: [mockNavigatorObserver],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => DoseAndExpiryScreen(initialData: data),
          ),
          GoRoute(
            path: '/${AppRouter.therapySummaryRouteName}',
            name: AppRouter.therapySummaryRouteName,
            builder: (context, state) => const SizedBox.shrink(), 
          ),
        ],
      );

      await tester.pumpWidget(
        CupertinoApp.router(
          routerConfig: router,
        ),
      );
    }

    setUp(() {
      mockGoRouter = MockGoRouter();
      mockNavigatorObserver = MockNavigatorObserver();
    });

    // --- TEST CASE 1: Initial State (Create Mode) ---
    testWidgets('should display default values from the model in create mode', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Assert
      // Check that the default values from the model and initState are displayed.
      expect(find.text('1'), findsOneWidget);    // Dose Amount
      expect(find.text('20'), findsOneWidget);   // Initial Doses (from initState default)
      expect(find.text('10'), findsOneWidget);   // Threshold
      expect(find.text('Seleziona data'), findsOneWidget);
      expect(find.text('Avanti'), findsOneWidget);
    });

    // --- TEST CASE 2: User Interaction (Steppers) ---
    testWidgets('stepper buttons should update the displayed values', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Act
      // Find the increment button for the "Initial Doses" stepper.
      final initialDosesIncrement = find.descendant(
        of: find.widgetWithText(Row, '20'), // Find the row containing '20'
        matching: find.byIcon(CupertinoIcons.add_circled),
      );
      
      await tester.tap(initialDosesIncrement);
      await tester.pump(); 

      // Assert
      // The value should now be 21.
      expect(find.text('21'), findsOneWidget);
      expect(find.text('20'), findsNothing);
    });

    // --- TEST CASE 3: Date Picker ---
    testWidgets('tapping date selector button shows a date picker', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // Act
      await tester.tap(find.text('Seleziona data'));
      await tester.pumpAndSettle(); // Wait for the modal popup animation

      // Assert
      // The CupertinoDatePicker widget should now be on screen.
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
    });

    // --- TEST CASE 4: Navigation ---
    testWidgets('tapping Avanti navigates to summary screen with updated data', (tester) async {
      // Arrange
      final initialData = createInitialData();
      await pumpScreen(tester, data: initialData);

      // We'll increment the threshold to check if the data is passed correctly.
      final thresholdIncrement = find.descendant(
        of: find.widgetWithText(Row, '10'),
        matching: find.byIcon(CupertinoIcons.add_circled),
      );
      await tester.tap(thresholdIncrement);
      await tester.pump();
      
      // Act
      final avantiButton = find.text('Avanti');

      await tester.ensureVisible(avantiButton);
      await tester.pumpAndSettle(); // Wait for the scroll animation to finish.

      await tester.tap(avantiButton);
      await tester.pumpAndSettle();

      // Assert
      // The navigation will now succeed, and the screen will be gone.
      expect(find.byType(DoseAndExpiryScreen), findsNothing);
    });

    // --- TEST CASE 5: Navigation ---
    testWidgets('tapping Conferma pops the screen, removing it from view', (tester) async {
      // Arrange
      final initialData = createInitialData();
      initialData.isSingleEditMode = true; // Set the flag for edit mode

      // Set up the navigation stack
      await tester.pumpWidget(
        CupertinoApp.router(
          routerConfig: GoRouter(
            observers: [mockNavigatorObserver],
            routes: [
              GoRoute(path: '/', builder: (context, state) => const Text('Home Page')),
              GoRoute(
                path: '/dose',
                builder: (context, state) => DoseAndExpiryScreen(
                  initialData: state.extra as TherapySetupData,
                ),
              ),
            ],
          ),
        ),
      );
      
      // Push the screen and wait for it to appear
      final router = GoRouter.of(tester.element(find.text('Home Page')));
      router.push('/dose', extra: initialData);
      await tester.pumpAndSettle();
      expect(find.byType(DoseAndExpiryScreen), findsOneWidget);


      // Act
      final confermaButton = find.text('Conferma');

      await tester.ensureVisible(confermaButton);
      await tester.pumpAndSettle();

      await tester.tap(confermaButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DoseAndExpiryScreen), findsNothing);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}