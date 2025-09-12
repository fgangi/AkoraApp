// test/main_scaffold_screen_test.dart

import 'dart:async';
import 'package:akora_app/features/chat/screens/ai_doctor_screen.dart';
import 'package:akora_app/features/home/screens/home_screen.dart';
import 'package:akora_app/features/maps/screens/pharmacy_maps_screen.dart';
import 'package:akora_app/features/scaffold/main_scaffold_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';


void main() {
  group('MainScaffoldScreen Tests', () {
    // Mock objects for the screen's dependencies
    late MockAppDatabase mockDatabase;
    late MockNotificationService mockNotificationService;

    // Helper function to build the widget with mocked dependencies
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

    // Set up mocks before each test
    setUp(() {
      mockDatabase = MockAppDatabase();
      mockNotificationService = MockNotificationService();

      // Stub for the HomeScreen's main stream
      when(mockDatabase.watchAllActiveTherapies()).thenAnswer((_) => Stream.value([]));

      // Stub for the TherapyCard's stream
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

      // Assert: Check that HomeScreen is displayed initially
      expect(
        find.descendant(
            of: find.byType(MainScaffoldScreen),
            matching: find.byType(HomeScreen)),
        findsOneWidget,
      );
      
      expect(find.byType(AiDoctorScreen), findsNothing);
      expect(find.byType(PharmacyMapsScreen), findsNothing);

      // Check that the tab bar labels are present
      expect(find.text('Dottore AI'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Trova Farmacie'), findsOneWidget);
    });

    // --- TEST CASE 2: Tapping the Third Tab ---
    testWidgets('should switch to PharmacyMapsScreen when third tab is tapped',
        (tester) async {
      // Arrange: Build the widget and wait for initial state
      await pumpMainScaffold(tester);
      await tester.pumpAndSettle();

      // Act: Find and tap the "Trova Farmacie" tab
      await tester.tap(find.text('Trova Farmacie'));
      await tester.pumpAndSettle();

      // Assert: The visible screen should now be PharmacyMapsScreen
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