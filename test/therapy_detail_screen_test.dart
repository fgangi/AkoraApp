// test/therapy_detail_screen_test.dart

import 'package:akora_app/core/navigation/app_router.dart';
import 'package:akora_app/data/sources/local/app_database.dart';
import 'package:akora_app/features/therapy_management/models/therapy_enums.dart';
import 'package:akora_app/features/therapy_management/screens/therapy_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

// We need the MockGoRouter
import 'home_screen_test.mocks.dart';

void main() {
  group('TherapyDetailScreen', () {
    late MockGoRouter mockGoRouter;

    // A helper function to create a fake therapy
    Therapy createTestTherapy({DateTime? expiryDate}) {
      return Therapy(
        id: 1,
        drugName: 'Paracetamol',
        drugDosage: '500mg',
        doseAmount: '1',
        takingFrequency: TakingFrequency.twiceDaily,
        reminderTimes: ['08:00', '20:00'],
        //repeatAfter10Min: false,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 10),
        doseThreshold: 15,
        isActive: true,
        isPaused: false,
        expiryDate: expiryDate,
      );
    }

    // A helper function to build our screen
    Future<void> pumpScreen(WidgetTester tester, {required Therapy therapy}) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: TherapyDetailScreen(therapy: therapy),
          ),
        ),
      );
    }

    setUp(() {
      mockGoRouter = MockGoRouter();
    });

    // --- TEST CASE 1: UI Verification ---
    testWidgets('should display all therapy details correctly', (tester) async {
      // Arrange
      final therapy = createTestTherapy(expiryDate: DateTime(2025, 12, 31));
      
      // Act
      await pumpScreen(tester, therapy: therapy);

      // Assert
      // Check that all the data from the therapy object is rendered on screen.
      expect(find.text('Paracetamol'), findsOneWidget); 
      expect(find.text('Paracetamol 500mg'), findsOneWidget);
      expect(find.text('Due volte al giorno (08:00, 20:00)'), findsOneWidget);
      expect(find.text('Dal 01/01/2024 al 10/01/2024'), findsOneWidget);
      expect(find.text('Avviso a 15 dosi rimanenti'), findsOneWidget);
      expect(find.text('31/12/2025'), findsOneWidget); // Expiry date
    });
    

    // --- TEST CASE 2: Navigation ---
    testWidgets('tapping Modifica button should navigate to edit flow', (tester) async {
      // Arrange
      final therapy = createTestTherapy();
      when(mockGoRouter.pushNamed(any, extra: anyNamed('extra')))
          .thenAnswer((_) async => null);

      await pumpScreen(tester, therapy: therapy);

      // Act
      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockGoRouter.pushNamed(
        AppRouter.addTherapyStartRouteName,
        extra: therapy,
      )).called(1);
    });
  });
}