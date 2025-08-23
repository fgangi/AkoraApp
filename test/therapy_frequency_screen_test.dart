// test/therapy_frequency_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_frequency_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

// mock
import 'home_screen_test.mocks.dart';
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('TherapyFrequencyScreen', () {
    late MockGoRouter mockGoRouter;
    late MockNavigatorObserver mockNavigatorObserver;

    //fake data
    TherapySetupData createInitialData({
      TakingFrequency frequency = TakingFrequency.onceDaily,
      bool isSingleEditMode = false,
    }) {
      final drug = Drug(
        id: '1', name: 'Test Drug', dosage: '100mg', activeIngredient: '',
        quantityDescription: '', form: DrugForm.tablet,
      );
      return TherapySetupData(
        currentDrug: drug,
        selectedFrequency: frequency,
        reminderTimes: ['08:00'],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        doseThreshold: 10,
        doseAmount: '1',
        isSingleEditMode: isSingleEditMode,
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
            builder: (context, state) => TherapyFrequencyScreen(initialData: data),
          ),
          GoRoute(
            path: '/${AppRouter.reminderTimeRouteName}',
            name: AppRouter.reminderTimeRouteName,
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

    // --- TEST CASE 1: Initial UI ---
    testWidgets('should show the correct frequency as initially selected', (tester) async {
      // Arrange: Start with 'twiceDaily' selected.
      final initialData = createInitialData(frequency: TakingFrequency.twiceDaily);
      
      // Act
      await pumpScreen(tester, data: initialData);

      // Assert
      final selectedButton = find.ancestor(
        of: find.text('Due volte al giorno'),
        matching: find.byType(GestureDetector),
      );
      
      // The Container hould have the primary color.
      final container = tester.widget<Container>(find.descendant(
        of: selectedButton,
        matching: find.byType(Container),
      ));
      
      expect((container.decoration as BoxDecoration).color, isNot(CupertinoColors.tertiarySystemFill));
    });

    // --- TEST CASE 2: User Interaction ---
    testWidgets('tapping a different frequency button updates the selection', (tester) async {
      // Arrange: Start with 'onceDaily' selected.
      final initialData = createInitialData(frequency: TakingFrequency.onceDaily);
      await pumpScreen(tester, data: initialData);

      // Act: Tap the 'Una volta a settimana' button.
      await tester.tap(find.text('Una volta a settimana'));
      await tester.pump(); 

      // Assert
      final weeklyButton = find.ancestor(
        of: find.text('Una volta a settimana'),
        matching: find.byType(GestureDetector),
      );
      final container = tester.widget<Container>(find.descendant(
        of: weeklyButton,
        matching: find.byType(Container),
      ));
      // The button should now be the selected color.
      expect((container.decoration as BoxDecoration).color, isNot(CupertinoColors.tertiarySystemFill));
    });

    // --- TEST CASE 3: Conditional UI ---
    testWidgets('weekly reminder text is only visible when "onceWeekly" is selected', (tester) async {
      // Arrange
      final initialData = createInitialData(frequency: TakingFrequency.onceDaily);
      await pumpScreen(tester, data: initialData);
      
      final animatedOpacityFinder = find.ancestor(
        of: find.textContaining('Il promemoria verrà impostato'),
        matching: find.byType(AnimatedOpacity),
      );

      // Assert: Initially, the opacity should be 0.0 (invisible).
      var opacityWidget = tester.widget<AnimatedOpacity>(animatedOpacityFinder);
      expect(opacityWidget.opacity, 0.0);

      // Act: Tap the 'Una volta a settimana' button  
      await tester.tap(find.text('Una volta a settimana'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      // Assert: Now, the opacity should be 1.0 (fully visible).
      opacityWidget = tester.widget<AnimatedOpacity>(animatedOpacityFinder);
      expect(opacityWidget.opacity, 1.0);
    });

    // --- TEST CASE 4: Navigation (Create Mode) ---
    testWidgets('tapping Avanti navigates to reminder time screen with updated data', (tester) async {
      // Arrange
      final initialData = createInitialData(frequency: TakingFrequency.onceDaily);
      await pumpScreen(tester, data: initialData);
      
      // Act
      await tester.tap(find.text('Due volte al giorno'));
      await tester.pump();
      
      // tap the "Avanti" button.
      await tester.tap(find.text('Avanti'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TherapyFrequencyScreen), findsNothing);
    });

    // --- TEST CASE 5: Navigation (Edit Mode) ---
    testWidgets('tapping Conferma pops the screen', (tester) async {
      // Arrange
      final initialData = createInitialData(isSingleEditMode: true);
      
      await tester.pumpWidget(
        CupertinoApp.router(
          routerConfig: GoRouter(
            observers: [mockNavigatorObserver],
            routes: [
              GoRoute(path: '/', builder: (context, state) => const Text('Summary Page')),
              GoRoute(
                path: '/frequency',
                builder: (context, state) => TherapyFrequencyScreen(
                  initialData: state.extra as TherapySetupData,
                ),
              ),
            ],
          ),
        ),
      );

      final router = GoRouter.of(tester.element(find.text('Summary Page')));
      router.push('/frequency', extra: initialData);
      await tester.pumpAndSettle();
      
      // Act
      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TherapyFrequencyScreen), findsNothing);
      expect(find.text('Summary Page'), findsOneWidget);
    });
  });
}