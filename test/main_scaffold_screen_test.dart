// test/main_scaffold_screen_test.dart

import 'dart:async';
import 'dart:io'; 

import 'package:akora_app/core/services/notification_service.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/chat/screens/ai_doctor_screen.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/maps/screens/pharmacy_maps_screen.dart';
import 'package:akora_app/features/scaffold/main_scaffold_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Import the generated mock classes
import 'home_screen_test.mocks.dart';


void main() {
  group('MainScaffoldScreen Tests', () {
    // Declare the mock objects needed for the screen's dependencies.
    late MockAppDatabase mockDatabase;
    late MockNotificationService mockNotificationService;

    // Helper function to build the widget with mocked dependencies.
    Future<void> pumpMainScaffold(WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: MainScaffoldScreen(
            database: mockDatabase,
            notificationService: mockNotificationService,
          ),
        ),
      );
    }

    // This runs before each test, ensuring a clean state.
    setUp(() {
      mockDatabase = MockAppDatabase();
      mockNotificationService = MockNotificationService();

      //Stub for the HomeScreen's main stream
      when(mockDatabase.watchAllActiveTherapies()).thenAnswer((_) => Stream.value([]));

      //Stub for the TherapyCard's stream
      when(mockDatabase.watchDoseLogsForDay(
        therapyId: anyNamed('therapyId'),
        day: anyNamed('day'),
      )).thenAnswer((_) => Stream.value([]));
    });

    // --- TEST CASE 1: Initial State ---
    testWidgets('should display HomeScreen initially due to initialIndex being 1',
        (tester) async {
      // Arrange & Act: Build the widget and wait for animations.
      await pumpMainScaffold(tester);
      await tester.pumpAndSettle();

      // Assert:
      expect(
        find.descendant(
            of: find.byType(MainScaffoldScreen),
            matching: find.byType(HomeScreen)),
        findsOneWidget,
      );
      
      expect(find.byType(AiDoctorScreen), findsNothing);
      expect(find.byType(PharmacyMapsScreen), findsNothing);

      // Check that the tab bar LABELS are present by finding their text directly.
      expect(find.text('Dottore AI'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Trova Farmacie'), findsOneWidget);
    });

    // --- TEST CASE 2: Tapping the First Tab ---
    /*
    testWidgets('should switch to AiDoctorScreen when first tab is tapped',
        (tester) async {
      // Arrange:
      // Use the pragmatic fix: temporarily set the environment variable that the real
      // AiApiService will read. This prevents it from crashing during initialization.
      Platform.environment['OPENAI_API_KEY'] = 'fake_key_for_testing';
      
      await pumpMainScaffold(tester);
      await tester.pumpAndSettle();

      // Act: Find the "Dottore AI" tab by its text and tap it.
      await tester.tap(find.text('Dottore AI'));
      // Wait for the tab switch animation to complete.
      await tester.pumpAndSettle();

      // Assert: The visible screen should now be AiDoctorScreen.
      expect(
        find.descendant(
            of: find.byType(MainScaffoldScreen),
            matching: find.byType(AiDoctorScreen)),
        findsOneWidget,
      );
      expect(find.byType(HomeScreen), findsNothing);

      // Cleanup: It's good practice to remove the fake key after the test.
      Platform.environment.remove('OPENAI_API_KEY');
    });
*/
    // --- TEST CASE 3: Tapping the Third Tab ---
    testWidgets('should switch to PharmacyMapsScreen when third tab is tapped',
        (tester) async {
      // Arrange:
      await pumpMainScaffold(tester);
      await tester.pumpAndSettle();

      // Act: Find the "Trova Farmacie" tab by its text and tap it.
      await tester.tap(find.text('Trova Farmacie'));
      await tester.pumpAndSettle();

      // Assert: The visible screen should now be PharmacyMapsScreen.
      expect(
        find.descendant(
            of: find.byType(MainScaffoldScreen),
            matching: find.byType(PharmacyMapsScreen)),
        findsOneWidget,
      );
      expect(find.byType(HomeScreen), findsNothing);
    });
  });
}