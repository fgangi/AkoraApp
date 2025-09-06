import 'dart:async';
import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/home/widgets/therapy_card.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_detail_screen.dart';
import 'package:akora_app/features/home/widgets/empty_detail_scaffold.dart';

import 'home_screen_test.mocks.dart';
import 'package:akora_app/core/services/ai_api_service.dart';
import 'package:akora_app/features/maps/services/maps_service.dart';

// This annotation MUST be here to tell the builder WHAT to generate.
@GenerateMocks([AppDatabase, NotificationService, GoRouter,])

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
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 10)),
      doseThreshold: 10,
      isActive: true,
      isPaused: false,
    );
  }

  // helper to build the screen and allow setting screen size
  Future<void> pumpHomeScreen(WidgetTester tester, {Size? screenSize}) async {
    // 1. Create a REAL GoRouter for the test, with our screen as a route.
    //    This is more robust than using InheritedGoRouter.
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeScreen(
            database: mockDatabase,
            notificationService: mockNotificationService,
          ),
        ),
        // Add dummy routes for any navigation targets to prevent errors
        GoRoute(
          path: '/${AppRouter.therapyDetailRouteName}',
          name: AppRouter.therapyDetailRouteName,
          builder: (c, s) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/${AppRouter.addTherapyStartRouteName}',
          name: AppRouter.addTherapyStartRouteName,
          builder: (c, s) => const SizedBox.shrink(),
        ),
      ],
    );

    // 2. Define the widget we will pump.
    Widget testWidget = MaterialApp.router(
      // Use the .router constructor to integrate GoRouter properly.
      routerConfig: router,
      // We can wrap this in a CupertinoTheme to ensure Cupertino styles are available.
      builder: (context, child) => CupertinoTheme(
        data: const CupertinoThemeData(),
        child: child!,
      ),
    );

    // 3. If a screen size is provided, wrap the entire app in a MediaQuery.
    if (screenSize != null) {
      testWidget = MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: testWidget,
      );
    }

    // 4. Pump the final, complete widget tree.
    await tester.pumpWidget(testWidget);
  }

  // setUp is a function that runs BEFORE each test to reset the mocks.
  setUp(() {
      mockDatabase = MockAppDatabase();
      mockNotificationService = MockNotificationService();
      mockGoRouter = MockGoRouter();
      therapiesStreamController = StreamController<List<Therapy>>.broadcast();

      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra'))).thenAnswer((_) async => null);
      when(mockDatabase.watchAllActiveTherapies()).thenAnswer((_) => therapiesStreamController.stream);
      when(mockDatabase.watchDoseLogsForDay(therapyId: anyNamed('therapyId'), day: anyNamed('day')))
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabase.deleteTherapy(any)).thenAnswer((_) async => 1);
      when(mockNotificationService.cancelTherapyNotifications(any)).thenAnswer((_) async {});
  });

  // cleanUp function
  tearDown(() {
    therapiesStreamController.close();
  });


  group('Phone Layout', () {
    // --- TEST CASE 1: Loading State ---
    testWidgets('shows loading indicator while stream is waiting for data',
        (tester) async {
      // Arrange: The `setUp` function has already prepared the mocks.
      // The stream hasn't received any data yet, so it's in a "waiting" state.

      // Act: Build the HomeScreen widget.
      await pumpHomeScreen(tester);

      // Assert:
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      // We expect that the list of therapies is NOT on screen yet.
      expect(find.byType(ListView), findsNothing);
    });

    // --- TEST CASE 2: Empty State ---
    testWidgets('shows empty message when stream provides an empty list',
        (tester) async {
      // Arrange:
      await pumpHomeScreen(tester);

      // Act: simulating the database returning zero therapies.
      therapiesStreamController.add([]);
      await tester.pump();

      // Assert:
      // We expect to find the specific "Nessuna terapia attiva" text.
      expect(find.text('Nessuna terapia attiva.\nTocca il pulsante + per aggiungerne una.'), findsOneWidget);
      // We expect that the ListView is still not visible.
      expect(find.byType(ListView), findsNothing);
    });

    // --- TEST CASE 3: Data Loaded State ---
    testWidgets('displays a list of therapies when the stream provides data',
        (tester) async {
      
      const phoneScreenSize = Size(414, 896); 
      await tester.binding.setSurfaceSize(phoneScreenSize);
      // It's good practice to reset the size after the test.
      addTearDown(() => tester.binding.setSurfaceSize(null));
      // Arrange:
      final therapies = [
        createDummyTherapy(id: 1, name: 'Aspirin'),
        createDummyTherapy(id: 2, name: 'Ibuprofen'),
      ];
      await pumpHomeScreen(tester, screenSize: phoneScreenSize);

      // Act: Push our list of dummy therapies into the stream.
      therapiesStreamController.add(therapies);
      await tester.pumpAndSettle();

      // Assert:
      expect(find.byType(ListView), findsOneWidget);
      // We expect to find exactly two TherapyCard widgets.
      expect(find.byType(TherapyCard), findsNWidgets(2));
    });

    // --- TEST CASE 4: Add Button Navigation ---
    testWidgets('tapping add button calls router to navigate', (tester) async {
      // Arrange:
      await pumpHomeScreen(tester);
      // Push empty data just to get out of the loading state.
      therapiesStreamController.add([]);
      await tester.pump();

      // Act: add button tap
      await tester.tap(find.byIcon(CupertinoIcons.add));
      await tester.pump(); 

      // Assert: check if a method on our mock object was called.
      verify(mockGoRouter.pushNamed(AppRouter.addTherapyStartRouteName)).called(1);
    });
    
    // --- TEST CASE 5: Therapy Card Navigation ---
    /*testWidgets('tapping a therapy card navigates to detail screen', (tester) async {
      // Arrange
      final therapy = createDummyTherapy(id: 1, name: 'Aspirin');
      
      final mockDatabase = MockAppDatabase();
      final mockNotificationService = MockNotificationService();
      final mockGoRouter = MockGoRouter();

      when(mockDatabase.watchDoseLogsForDay(therapyId: anyNamed('therapyId'), day: anyNamed('day')))
        .thenAnswer((_) => Stream.value([]));
      
      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
        .thenAnswer((_) async => null);

      // We pump ONLY the TherapyCard, wrapped in the necessary providers.
      await tester.pumpWidget(
        CupertinoApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: TherapyCard(
              therapy: therapy,
              database: mockDatabase,
              notificationService: mockNotificationService,
              // We provide a dummy onTap that does nothing.
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byType(TherapyCard));
      await tester.pumpAndSettle();

      // Assert
      // We verify that a navigation event happened. This will now pass because
      // the GoRouter is attached to the TherapyCard's context.
      verify(mockGoRouter.pushNamed(
        AppRouter.therapyDetailRouteName,
        extra: therapy,
      )).called(1);
    });*/

      // --- TEST CASE 6: Edit Navigation ---
    testWidgets('sliding item and tapping edit navigates correctly', (tester) async {
      const phoneScreenSize = Size(414, 896);
      await tester.binding.setSurfaceSize(phoneScreenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      // Arrange
      final therapyToEdit = createDummyTherapy(id: 1, name: 'Paracetamol');
      await pumpHomeScreen(tester, screenSize: phoneScreenSize);
      therapiesStreamController.add([therapyToEdit]);
      await tester.pumpAndSettle();

      // Act
      await tester.drag(find.byType(TherapyCard), const Offset(-200.0, 0.0));
      await tester.pump(const Duration(milliseconds: 500)); 
      await tester.tap(find.byIcon(CupertinoIcons.pencil));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('Add/Edit Screen'), findsOneWidget);
    });

    // --- TEST CASE 7: Delete Action ---
    testWidgets('deleting a therapy shows dialog and calls services', (tester) async {
      const phoneScreenSize = Size(414, 896);
      await tester.binding.setSurfaceSize(phoneScreenSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      // Arrange:
      final therapyToDelete = createDummyTherapy(id: 1, name: 'Aspirin');
      
      when(mockNotificationService.cancelTherapyNotifications(any)).thenAnswer((_) async {});
      when(mockDatabase.deleteTherapy(any)).thenAnswer((_) async => 1);
      
      await pumpHomeScreen(tester, screenSize: phoneScreenSize);
      therapiesStreamController.add([therapyToDelete]);
      await tester.pumpAndSettle();

      // ACT 1: Open the dialog.
      await tester.drag(find.byType(TherapyCard), const Offset(-200.0, 0.0));
      await tester.pump(const Duration(milliseconds: 500));

      // Find the delete button
      final deleteButtonIcon = find.byIcon(CupertinoIcons.delete);
      expect(deleteButtonIcon, findsOneWidget); 
      
      // Tap the found icon.
      await tester.tap(deleteButtonIcon);
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
  });

  group('Tablet Layout', () {
    const tabletSize = Size(800, 1200); 

    testWidgets('tapping a therapy card shows detail view on the right', (tester) async {
      // Arrange
      // Set the screen size to simulate a tablet
      await tester.binding.setSurfaceSize(tabletSize);
      // Ensure the MediaQuery is rebuilt with the new size
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final therapy = createDummyTherapy(id: 1, name: 'Aspirin');
      await pumpHomeScreen(tester, screenSize: tabletSize);
      therapiesStreamController.add([therapy]);
      await tester.pumpAndSettle();

      // Initially, the detail screen is not shown
      expect(find.byType(TherapyDetailScreen), findsNothing);

      // Act
      await tester.tap(find.byType(TherapyCard));
      await tester.pump(); 

      // Assert
      // The detail screen should now be visible on the right.
      expect(find.byType(TherapyDetailScreen), findsOneWidget);
      // Check that it's displaying the correct data.
      expect(find.text('Aspirin'), findsWidgets);
    });

    testWidgets('tapping add button navigates to add therapy route on tablet', (tester) async {
    // Arrange
    await tester.binding.setSurfaceSize(tabletSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpHomeScreen(tester, screenSize: tabletSize);
    therapiesStreamController.add([]);
    await tester.pumpAndSettle();

    // Act: Tap the add button.
    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();

    // Assert: Verify navigation happened.
    verify(mockGoRouter.pushNamed(AppRouter.addTherapyStartRouteName)).called(1);
  });

  testWidgets('sliding and tapping delete on the SELECTED therapy clears the detail view', (tester) async {
    // Arrange
    await tester.binding.setSurfaceSize(tabletSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final therapy = createDummyTherapy(id: 1, name: 'Aspirin');
    await pumpHomeScreen(tester, screenSize: tabletSize);
    therapiesStreamController.add([therapy]);
    await tester.pumpAndSettle();

    // First, tap the card to select it and show it in the detail view.
    await tester.tap(find.byType(TherapyCard));
    await tester.pump();
    expect(find.byType(TherapyDetailScreen), findsOneWidget); 

    // Slide the card and tap the delete icon.
    await tester.drag(find.byType(TherapyCard), const Offset(-200.0, 0.0));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(CupertinoIcons.delete));
    await tester.pumpAndSettle();

    // Confirm the deletion 
    await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Elimina'));
    await tester.pumpAndSettle();

    // Assert:
    // The TherapyDetailScreen should now be gone
    expect(find.byType(TherapyDetailScreen), findsNothing);
    expect(find.byType(EmptyDetailScaffold), findsOneWidget);
  });
  });
  
}