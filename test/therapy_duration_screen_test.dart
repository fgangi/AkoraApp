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
  });
}