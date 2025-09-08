// test/drug_search_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/features/therapy_management/screens/drug_search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:go_router/go_router.dart';

// We need the MockGoRouter and a dummy Therapy object.
import 'package:akora_app/data/sources/local/app_database.dart';
import 'home_screen_test.mocks.dart';

//dummy Therapy
Therapy createDummyTherapy() {
  return Therapy(
    id: 1,
    drugName: 'Aspirin',
    drugDosage: '100mg',
    doseAmount: '1',
    takingFrequency: TakingFrequency.onceDaily,
    reminderTimes: ['08:00'],
    //repeatAfter10Min: false,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 10)),
    doseThreshold: 10,
    isActive: true,
    isPaused: false,
  );
}

void main() {
  group('DrugSearchScreen', () {
    late MockGoRouter mockGoRouter;

    // A helper function to build our screen
    Future<void> pumpScreen(WidgetTester tester, {Therapy? initialTherapy}) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: DrugSearchScreen(initialTherapy: initialTherapy),
          ),
        ),
      );
    }

    setUp(() {
      mockGoRouter = MockGoRouter();
    });

    // --- TEST CASE 1: Edit Mode Logic ---
    testWidgets('when in edit mode, should immediately pushReplacement to frequency screen',
        (tester) async {
      // Arrange
      final therapy = createDummyTherapy();
      //stub
      when(mockGoRouter.pushReplacementNamed(any, extra: anyNamed('extra')))
        .thenAnswer((_) => Future.value(null));

      // Act:
      await pumpScreen(tester, initialTherapy: therapy);
      await tester.pump();
      // Assert
      // We verify that the router was told to replace the current screen.
      final captured = verify(mockGoRouter.pushReplacementNamed(
        AppRouter.therapyFrequencyRouteName,
        extra: captureAnyNamed('extra'),
      )).captured;

      // Check that the data passed along was correctly created from the therapy.
      final capturedData = captured.first as TherapySetupData;
      expect(capturedData.currentDrug.name, 'Aspirin');
      expect(capturedData.initialTherapy, isNotNull);
    });

    // --- TEST CASE 2: Create Mode Initial UI ---
    testWidgets('when in create mode, should display initial empty state message',
        (tester) async {
      // Arrange & Act
      await pumpScreen(tester);

      // Assert
      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(find.text('Inizia a digitare per cercare un farmaco.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    // --- TEST CASE 3: Search Interaction ---
    testWidgets('typing in search field should show results in a ListView',
        (tester) async {
      // Arrange
      await pumpScreen(tester);

      // Act
      final searchField = find.byType(CupertinoSearchTextField);
      expect(searchField, findsOneWidget);

      // Simulate the user entering text.
      await tester.enterText(searchField, 'Tachipirina');
      await tester.pumpAndSettle();

      // Assert
      // The ListView of results should now be visible.
      expect(find.byType(ListView), findsOneWidget);
      // The "no results" and "start typing" messages should be gone.
      expect(find.text('Nessun farmaco trovato.'), findsNothing);
      expect(find.text('Inizia a digitare per cercare un farmaco.'), findsNothing);
      //check for a specific result.
      expect(find.textContaining('Tachipirina 500mg'), findsOneWidget);
    });

    // --- TEST CASE 4: No Results Found ---
    testWidgets('typing a query with no matches should show "Nessun farmaco trovato"',
        (tester) async {
      // Arrange
      await pumpScreen(tester);

      // Act
      await tester.enterText(find.byType(CupertinoSearchTextField), 'NonExistentDrug123');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nessun farmaco trovato.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    // --- TEST CASE 5: Selection Navigation ---
    testWidgets('tapping a search result should navigate to frequency screen',
        (tester) async {
      // Arrange
      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra'))).thenAnswer((_) async {});
      await pumpScreen(tester);
      // We'll search for "Aspi" to find "Aspirina"
      await tester.enterText(find.byType(CupertinoSearchTextField), 'Aspi');
      await tester.pumpAndSettle();

      // Act
      // Find the specific result list item and tap it.
      final resultToTap = find.textContaining('Aspirina');
      expect(resultToTap, findsOneWidget);
      await tester.tap(resultToTap);
      await tester.pumpAndSettle();

      // Assert
      // Verify that we navigated to the next screen in the flow.
      final captured = verify(mockGoRouter.pushNamed(
        AppRouter.therapyFrequencyRouteName,
        extra: captureAnyNamed('extra'),
      )).captured;

      // Check that the data passed along contains the drug we selected.
      final capturedData = captured.first as TherapySetupData;
      expect(capturedData.currentDrug.name, 'Aspirina');
    });
  });
}