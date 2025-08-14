import 'dart:async';
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/home/widgets/therapy_card.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';

// This annotation MUST be here to tell the builder WHAT to generate.
@GenerateMocks([AppDatabase, NotificationService, GoRouter])

void main() {
  //declare mock objects 
  late MockAppDatabase mockDatabase;
  late MockNotificationService mockNotificationService;
  late MockGoRouter mockGoRouter;
  late StreamController<List<Therapy>> therapiesStreamController;

  // fuction to create a dummy therapy for testing
  Therapy createDummyTherapy({required int id, required String name}) {
    return Therapy(
      id: id,
      drugName: name,
      drugDosage: '500mg',
      doseAmount: '1',
      takingFrequency: TakingFrequency.onceDaily,
      reminderTimes: ['08:00'],
      repeatAfter10Min: false,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 10)),
      doseThreshold: 10,
      isActive: true,
      isPaused: false,
    );
  }

  // setUp is a function that runs BEFORE each test to reset the mocks.
  setUp(() {
    mockDatabase = MockAppDatabase();
    mockNotificationService = MockNotificationService();
    mockGoRouter = MockGoRouter();
    // This controller lets us manually push data into our widget's stream.
    therapiesStreamController = StreamController<List<Therapy>>.broadcast();
    // When watchAllActiveTherapies is called, return our controlled stream.
    when(mockDatabase.watchAllActiveTherapies()).thenAnswer((_) => therapiesStreamController.stream);
    //This prevents the therapy card from crashing
    when(mockDatabase.watchDoseLogsForDay(therapyId: anyNamed('therapyId'), day: anyNamed('day')))
      .thenAnswer((_) => Stream.value([]));
    // This tells the mock router how to handle the pushNamed call.
    when(mockGoRouter.pushNamed(any, extra: anyNamed('extra'))).thenAnswer((_) async => {});
  });

  // cleanUp function
  tearDown(() {
    therapiesStreamController.close();
  });

  // A helper function to build widget for testing.
  // It wraps HomeScreen in the necessary providers to make it work.
  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: HomeScreen(
            database: mockDatabase,
            notificationService: mockNotificationService,
          ),
        ),
      ),
    );
}

// --- TEST CASE 1: Loading State ---
  testWidgets('shows loading indicator while stream is waiting for data',
      (tester) async {
    // Arrange: The `setUp` function has already prepared the mocks.
    // The stream hasn't received any data yet, so it's in a "waiting" state.

    // Act: Build the HomeScreen widget.
    await pumpHomeScreen(tester);

    // Assert: We expect to find exactly one loading spinner.
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    // We expect that the list of therapies is NOT on screen yet.
    expect(find.byType(ListView), findsNothing);
  });

  // --- TEST CASE 2: Empty State ---
  testWidgets('shows empty message when stream provides an empty list',
      (tester) async {
    // Arrange: Build the widget.
    await pumpHomeScreen(tester);

    // Act: Manually push an empty list into our stream controller,
    // simulating the database returning zero therapies.
    therapiesStreamController.add([]);
    // `tester.pump()` tells Flutter to rebuild the widget with the new state.
    await tester.pump();

    // Assert:
    // We expect to find the specific "no active therapies" text.
    expect(find.text('Nessuna terapia attiva.\nTocca il pulsante + per aggiungerne una.'), findsOneWidget);
    // We expect that the ListView is still not visible.
    expect(find.byType(ListView), findsNothing);
  });

  // --- TEST CASE 3: Data Loaded State ---
  testWidgets('displays a list of therapies when the stream provides data',
      (tester) async {
    // Arrange:
    final therapies = [
      createDummyTherapy(id: 1, name: 'Aspirin'),
      createDummyTherapy(id: 2, name: 'Ibuprofen'),
    ];
    await pumpHomeScreen(tester);

    // Act: Push our list of dummy therapies into the stream.
    therapiesStreamController.add(therapies);
    await tester.pump(); // Rebuild the widget.

    // Assert:
    // We expect to find the ListView on screen.
    expect(find.byType(ListView), findsOneWidget);
    // We expect to find exactly two TherapyCard widgets.
    expect(find.byType(TherapyCard), findsNWidgets(2));
    // We can even check for the specific drug names.
    expect(find.text('Aspirin'), findsOneWidget);
    expect(find.text('Ibuprofen'), findsOneWidget);
  });

  // --- TEST CASE 4: Add Button Navigation ---
  testWidgets('tapping add button calls router to navigate', (tester) async {
    // Arrange:
    await pumpHomeScreen(tester);
    // Push empty data just to get out of the loading state.
    therapiesStreamController.add([]);
    await tester.pump();

    // Act: Find the add button by its icon and simulate a tap.
    //expect(find.byIcon(CupertinoIcons.add), findsOneWidget, reason: 'The add button icon should be on screen');
    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pump(); // Allow time for navigation to be processed.

    // Assert:
    // Use Mockito's `verify` to check if a method on our mock object was called.
    // We verify that pushNamed was called on mockGoRouter exactly once,
    // with the correct route name as its argument.
    verify(mockGoRouter.pushNamed(AppRouter.addTherapyStartRouteName)).called(1);
  });

  // --- TEST CASE 5: Edit Action ---
  testWidgets('sliding item and tapping Edit navigates with therapy data',
      (tester) async {
    // Arrange:
    final therapyToEdit = createDummyTherapy(id: 1, name: 'Paracetamol');
    await pumpHomeScreen(tester);
    therapiesStreamController.add([therapyToEdit]);
    // `pumpAndSettle` waits for all animations to complete.
    await tester.pumpAndSettle();

    // Act:
    // 1. Simulate a drag gesture on the TherapyCard to reveal the actions.
    await tester.drag(find.byType(TherapyCard), const Offset(-200.0, 0.0));
    await tester.pumpAndSettle(); // Wait for the slide animation.

    // 2. Find the "Modifica" button and tap it.
    await tester.tap(find.widgetWithText(SlidableAction, 'Modifica'));
    await tester.pumpAndSettle();

    // Assert:
    // Verify that the router was called with the correct route name AND
    // with the correct therapy object passed in the 'extra' parameter.
    verify(mockGoRouter.pushNamed(
      AppRouter.addTherapyStartRouteName,
      extra: therapyToEdit,
    )).called(1);
  });

  // --- TEST CASE 6: Delete Action ---
  testWidgets('deleting a therapy shows dialog and calls services',
      (tester) async {
    // Arrange:
    final therapyToDelete = createDummyTherapy(id: 1, name: 'Aspirin');
    // Tell our mocks how to behave when their delete methods are called.
    // For methods that return a Future, we use `thenAnswer`.
    when(mockNotificationService.cancelTherapyNotifications(any))
        .thenAnswer((_) async {});
    when(mockDatabase.deleteTherapy(any)).thenAnswer((_) async => 1);
    await pumpHomeScreen(tester);
    therapiesStreamController.add([therapyToDelete]);
    await tester.pumpAndSettle();

    // ACT 1: Open the dialog.
    await tester.drag(find.byType(TherapyCard), const Offset(-200.0, 0.0));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SlidableAction, 'Elimina'));
    await tester.pumpAndSettle();

    // ASSERT 1: The dialog is visible.
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Conferma Eliminazione'), findsOneWidget);

    // ACT 2: Tap the final confirmation button in the dialog.
    await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Elimina'));
    await tester.pumpAndSettle();

    // ASSERT 2:
    // Verify that our mock services were called with the correct data.
    verify(mockNotificationService.cancelTherapyNotifications(therapyToDelete)).called(1);
    verify(mockDatabase.deleteTherapy(therapyToDelete.id)).called(1);
    // And verify that the dialog is now gone.
    expect(find.byType(CupertinoAlertDialog), findsNothing);
  });
}