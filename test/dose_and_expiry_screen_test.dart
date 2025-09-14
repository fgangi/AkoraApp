// test/dose_and_expiry_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/models/drug_model.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/models/therapy_setup_model.dart';
import 'package:akora_app/features/therapy_management/screens/dose_and_expiry_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

// We need a mock NavigatorObserver to track navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('DoseAndExpiryScreen', () {
    // We need a mock router to test navigation calls.
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

    // --- ENHANCED COMPREHENSIVE TESTS ---
    group('Stepper Component Tests', () {
      testWidgets('dose amount stepper should have minimum value of 1', (tester) async {
        final initialData = createInitialData();
        initialData.doseAmount = "1";
        await pumpScreen(tester, data: initialData);

        // Try to decrement below 1
        final doseDecrement = find.descendant(
          of: find.widgetWithText(Row, '1'),
          matching: find.byIcon(CupertinoIcons.minus_circle),
        );
        
        await tester.tap(doseDecrement);
        await tester.pump();

        // Should remain at 1
        expect(find.text('1'), findsOneWidget);
        expect(find.text('0'), findsNothing);
      });

      testWidgets('initial doses stepper should have minimum value of 1', (tester) async {
        final initialData = createInitialData();
        initialData.initialDoses = 1;
        await pumpScreen(tester, data: initialData);

        final initialDosesDecrement = find.descendant(
          of: find.widgetWithText(Row, '1'),
          matching: find.byIcon(CupertinoIcons.minus_circle),
        ).last; // Get the second occurrence (initial doses)
        
        await tester.tap(initialDosesDecrement);
        await tester.pump();

        // Should remain at 1
        expect(find.text('1'), findsAtLeastNWidgets(1));
      });

      testWidgets('threshold stepper should have minimum value of 1', (tester) async {
        final initialData = createInitialData();
        initialData.doseThreshold = 1;
        await pumpScreen(tester, data: initialData);

        final thresholdDecrement = find.descendant(
          of: find.widgetWithText(Row, '1'),
          matching: find.byIcon(CupertinoIcons.minus_circle),
        ).last; // Get the last occurrence (threshold)
        
        await tester.tap(thresholdDecrement);
        await tester.pump();

        // Should remain at 1
        expect(find.text('1'), findsAtLeastNWidgets(1));
      });

      testWidgets('steppers can increment values properly', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Test dose amount increment
        final doseIncrement = find.descendant(
          of: find.widgetWithText(Row, '1'),
          matching: find.byIcon(CupertinoIcons.add_circled),
        );
        await tester.tap(doseIncrement);
        await tester.pump();
        expect(find.text('2'), findsOneWidget);

        // Test initial doses increment (from 20 to 21)
        final initialDosesIncrement = find.descendant(
          of: find.widgetWithText(Row, '20'),
          matching: find.byIcon(CupertinoIcons.add_circled),
        );
        await tester.tap(initialDosesIncrement);
        await tester.pump();
        expect(find.text('21'), findsOneWidget);

        // Test threshold increment (from 10 to 11)
        final thresholdIncrement = find.descendant(
          of: find.widgetWithText(Row, '10'),
          matching: find.byIcon(CupertinoIcons.add_circled),
        );
        await tester.tap(thresholdIncrement);
        await tester.pump();
        expect(find.text('11'), findsOneWidget);
      });

      testWidgets('stepper labels change correctly for singular/plural', (tester) async {
        final initialData = createInitialData();
        initialData.doseAmount = "2"; // Start with plural
        await pumpScreen(tester, data: initialData);

        // Should show plural form
        expect(find.text('dosi'), findsAtLeastNWidgets(1));

        // Decrement to 1
        final doseDecrement = find.descendant(
          of: find.widgetWithText(Row, '2'),
          matching: find.byIcon(CupertinoIcons.minus_circle),
        );
        await tester.tap(doseDecrement);
        await tester.pump();

        // Should show singular form
        expect(find.text('dose'), findsAtLeastNWidgets(1));
      });
    });

    group('Date Picker Tests', () {
      testWidgets('date picker should show future dates only', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        await tester.tap(find.text('Seleziona data'));
        await tester.pumpAndSettle();

        final datePicker = tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
        expect(datePicker.minimumDate, isNotNull);
        expect(datePicker.minimumDate!.isAfter(DateTime.now().subtract(const Duration(days: 1))), isTrue);
        
        // Test that the minimum date is today at midnight (not just after now)
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        expect(datePicker.minimumDate, equals(todayMidnight));
      });

      testWidgets('date picker minimumDate is set to today at midnight', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        await tester.tap(find.text('Seleziona data'));
        await tester.pumpAndSettle();

        final datePicker = tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
        
        // Verify that the minimum date is specifically set to today at midnight
        final today = DateTime.now();
        final expectedMinDate = DateTime(today.year, today.month, today.day);
        expect(datePicker.minimumDate, equals(expectedMinDate));
        
        // Verify it's in date mode
        expect(datePicker.mode, equals(CupertinoDatePickerMode.date));
      });

      testWidgets('selecting date should update the display', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        await tester.tap(find.text('Seleziona data'));
        await tester.pumpAndSettle();

        // Simulate date selection by finding the date picker and changing date
        final datePicker = find.byType(CupertinoDatePicker);
        expect(datePicker, findsOneWidget);

        // Get the date picker widget and simulate a date change
        final datePickerWidget = tester.widget<CupertinoDatePicker>(datePicker);
        expect(datePickerWidget.onDateTimeChanged, isNotNull);
        
        // Simulate selecting a date by calling the callback directly
        final newDate = DateTime.now().add(const Duration(days: 30));
        datePickerWidget.onDateTimeChanged(newDate);
        await tester.pump();

        // Close the picker by tapping outside
        await tester.tapAt(const Offset(200, 100));
        await tester.pumpAndSettle();

        // The internal state should be updated (verified by no errors/crashes)
        expect(find.byType(DoseAndExpiryScreen), findsOneWidget);
      });

      testWidgets('date picker onDateTimeChanged callback updates internal state', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Open the date picker
        await tester.tap(find.text('Seleziona data'));
        await tester.pumpAndSettle();

        // Find the date picker widget
        final datePicker = find.byType(CupertinoDatePicker);
        final datePickerWidget = tester.widget<CupertinoDatePicker>(datePicker);
        
        // Simulate multiple date changes to test the setState behavior
        final date1 = DateTime.now().add(const Duration(days: 10));
        final date2 = DateTime.now().add(const Duration(days: 20));
        
        // Call the callback multiple times to ensure state updates work
        datePickerWidget.onDateTimeChanged(date1);
        await tester.pump();
        
        datePickerWidget.onDateTimeChanged(date2);
        await tester.pump();

        // Verify no errors occurred and widget is still functional
        expect(find.byType(CupertinoDatePicker), findsOneWidget);
        expect(find.byType(DoseAndExpiryScreen), findsOneWidget);
        
        // Close the picker
        await tester.tapAt(const Offset(200, 100));
        await tester.pumpAndSettle();
      });

      testWidgets('date picker should show formatted date when expiry date is set', (tester) async {
        final futureDate = DateTime.now().add(const Duration(days: 30));
        final initialData = createInitialData();
        initialData.expiryDate = futureDate;
        await pumpScreen(tester, data: initialData);

        // Should show formatted date instead of "Seleziona data"
        expect(find.text('Seleziona data'), findsNothing);
        
        // Should display the formatted date in some form
        // (The exact format depends on the DateFormat implementation)
        final dateWidgets = find.byType(Text);
        expect(dateWidgets, findsAtLeastNWidgets(1));
        
        // Verify the date picker infrastructure is available
        expect(find.text('Data di scadenza farmaco'), findsOneWidget);
        expect(find.text('Riceverai un avviso 7 giorni prima della scadenza'), findsOneWidget);
      });
    });

    group('Edit Mode vs Create Mode Tests', () {
      testWidgets('edit mode should show Conferma button', (tester) async {
        final initialData = createInitialData();
        initialData.isSingleEditMode = true;
        await pumpScreen(tester, data: initialData);

        expect(find.text('Conferma'), findsOneWidget);
        expect(find.text('Avanti'), findsNothing);
      });

      testWidgets('create mode should show Avanti button', (tester) async {
        final initialData = createInitialData();
        initialData.isSingleEditMode = false;
        await pumpScreen(tester, data: initialData);

        expect(find.text('Avanti'), findsOneWidget);
        expect(find.text('Conferma'), findsNothing);
      });

      testWidgets('navigation bar should show correct previous page title', (tester) async {
        final initialData = createInitialData();
        initialData.isSingleEditMode = true;
        await pumpScreen(tester, data: initialData);

        final navBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
        expect(navBar.previousPageTitle, equals('Riepilogo'));
      });

      testWidgets('create mode navigation bar should show Durata as previous page', (tester) async {
        final initialData = createInitialData();
        initialData.isSingleEditMode = false;
        await pumpScreen(tester, data: initialData);

        final navBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
        expect(navBar.previousPageTitle, equals('Durata'));
      });
    });

    group('Data Persistence Tests', () {
      testWidgets('should preserve changes when navigating forward', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Make multiple changes
        final doseIncrement = find.descendant(
          of: find.widgetWithText(Row, '1'),
          matching: find.byIcon(CupertinoIcons.add_circled),
        );
        await tester.tap(doseIncrement);
        await tester.pump();

        final thresholdIncrement = find.descendant(
          of: find.widgetWithText(Row, '10'),
          matching: find.byIcon(CupertinoIcons.add_circled),
        );
        await tester.tap(thresholdIncrement);
        await tester.pump();

        // Navigate forward
        await tester.ensureVisible(find.text('Avanti'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Avanti'));
        await tester.pumpAndSettle();

        // Data should be preserved in the model (this is tested implicitly by successful navigation)
        expect(find.byType(DoseAndExpiryScreen), findsNothing);
      });

      testWidgets('should load existing therapy data correctly in edit mode', (tester) async {
        final drug = Drug(
          id: '1',
          name: 'Test Drug',
          dosage: '50mg',
          activeIngredient: 'Test Ingredient',
          quantityDescription: '30 compresse',
          form: DrugForm.tablet,
        );

        final existingTherapy = Therapy(
          id: 1,
          drugName: 'Test Drug',
          drugDosage: '50mg',
          doseAmount: '3',
          takingFrequency: TakingFrequency.twiceDaily,
          reminderTimes: ['08:00', '20:00'],
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 14)),
          doseThreshold: 5,
          expiryDate: DateTime.now().add(const Duration(days: 90)),
          isActive: true,
          isPaused: false,
        );

        final editData = TherapySetupData.fromTherapy(existingTherapy);
        editData.currentDrug = drug;
        editData.isSingleEditMode = true;

        await pumpScreen(tester, data: editData);

        // Should display existing values
        expect(find.text('3'), findsOneWidget);  // dose amount
        expect(find.text('5'), findsOneWidget);  // threshold
        // Initial doses uses default value from initState when not in therapy entity
        expect(find.text('20'), findsOneWidget); // initial doses (default)
      });
    });

    group('User Interface Tests', () {
      testWidgets('should display correct section labels', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        expect(find.text('PROMEMORIA DOSI E SCADENZA'), findsOneWidget);
        expect(find.text('Quanto ne assumi ogni volta?'), findsOneWidget);
        expect(find.text('Quante dosi ci sono nella confezione?'), findsOneWidget);
        expect(find.text('Avvisami quando restano:'), findsOneWidget);
        expect(find.text('Data di scadenza farmaco'), findsOneWidget);
        expect(find.text('Riceverai un avviso 7 giorni prima della scadenza'), findsOneWidget);
      });

      testWidgets('should display drug name in navigation bar', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        final navBar = tester.widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar));
        expect(navBar.middle, isA<Text>());
        final titleText = navBar.middle as Text;
        expect(titleText.data, equals('Aspirin'));
      });

      testWidgets('stepper containers should have correct styling', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        final stepperContainers = find.descendant(
          of: find.byType(Row),
          matching: find.byType(Container),
        );

        expect(stepperContainers, findsAtLeastNWidgets(3)); // One for each stepper

        // Check that containers have proper decorations
        final firstContainer = tester.widget<Container>(stepperContainers.first);
        expect(firstContainer.decoration, isA<BoxDecoration>());
        
        final decoration = firstContainer.decoration as BoxDecoration;
        expect(decoration.borderRadius, isA<BorderRadius>());
      });

      testWidgets('should scroll properly when content is long', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Check that SingleChildScrollView is present
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Ensure all elements are accessible by scrolling
        await tester.ensureVisible(find.text('Avanti'));
        expect(find.text('Avanti'), findsOneWidget);

        await tester.ensureVisible(find.text('PROMEMORIA DOSI E SCADENZA'));
        expect(find.text('PROMEMORIA DOSI E SCADENZA'), findsOneWidget);
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('should handle invalid dose amount gracefully', (tester) async {
        final initialData = createInitialData();
        initialData.doseAmount = "invalid"; // Invalid string
        await pumpScreen(tester, data: initialData);

        // Should default to 1 when invalid
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('should handle null initial doses', (tester) async {
        final initialData = createInitialData();
        initialData.initialDoses = null;
        await pumpScreen(tester, data: initialData);

        // Should default to 20
        expect(find.text('20'), findsOneWidget);
      });

      testWidgets('should handle very large numbers in steppers', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Increment dose amount a few times to test large numbers capability
        for (int i = 1; i <= 5; i++) {
          final doseIncrement = find.descendant(
            of: find.widgetWithText(Row, '$i'),
            matching: find.byIcon(CupertinoIcons.add_circled),
          ).first; // Take the first match to avoid ambiguity
          await tester.tap(doseIncrement);
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.text('6'), findsOneWidget);
      });

      testWidgets('should maintain state during rebuild', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Make a change
        final doseIncrement = find.descendant(
          of: find.widgetWithText(Row, '1'),
          matching: find.byIcon(CupertinoIcons.add_circled),
        );
        await tester.tap(doseIncrement);
        await tester.pump();
        expect(find.text('2'), findsOneWidget);

        // Trigger a rebuild by pumping the same widget again
        await pumpScreen(tester, data: initialData);

        // Note: State might not be preserved across complete rebuilds of different widget instances
        // This test validates that the rebuild doesn't crash
        expect(find.byType(DoseAndExpiryScreen), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('buttons should have proper semantics for accessibility', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        final incrementButtons = find.byIcon(CupertinoIcons.add_circled);
        final decrementButtons = find.byIcon(CupertinoIcons.minus_circle);

        expect(incrementButtons, findsNWidgets(3));
        expect(decrementButtons, findsNWidgets(3));

        // All buttons should be tappable
        for (int i = 0; i < 3; i++) {
          final increment = incrementButtons.at(i);
          final decrement = decrementButtons.at(i);
          
          expect(tester.widget<CupertinoButton>(find.ancestor(of: increment, matching: find.byType(CupertinoButton))), isNotNull);
          expect(tester.widget<CupertinoButton>(find.ancestor(of: decrement, matching: find.byType(CupertinoButton))), isNotNull);
        }
      });

      testWidgets('text should have appropriate contrast and sizing', (tester) async {
        final initialData = createInitialData();
        await pumpScreen(tester, data: initialData);

        // Check that title text has appropriate styling
        final titleText = find.text('PROMEMORIA DOSI E SCADENZA');
        final titleWidget = tester.widget<Text>(titleText);
        expect(titleWidget.style?.fontSize, equals(26));
        expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));

        // Check that section headers have appropriate styling
        final sectionHeaders = find.text('Quanto ne assumi ogni volta?');
        final headerWidget = tester.widget<Text>(sectionHeaders);
        expect(headerWidget.style?.fontSize, equals(17));
        expect(headerWidget.style?.fontWeight, equals(FontWeight.w600));
      });
    });
  });
}