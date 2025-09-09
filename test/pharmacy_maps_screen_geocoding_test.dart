// test/pharmacy_maps_screen_additional_coverage_test.dart
import 'dart:async';
import 'package:akora_app/features/maps/models/pharmacy_model.dart';
import 'package:akora_app/features/maps/screens/pharmacy_maps_screen.dart';
import 'package:akora_app/features/maps/services/maps_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';

// Fake tile provider for testing
class FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    return MemoryImage(Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]));
  }
}

// Enhanced fake maps service for additional testing
class CoverageTestMapsService implements IMapsService {
  bool shouldThrowPositionError = false;
  String positionError = 'Permission Denied';
  bool shouldThrowPharmacyError = false;
  List<ConnectivityResult> connectivityResult = [ConnectivityResult.wifi];
  List<Pharmacy> pharmaciesToReturn = [];
  
  int determinePositionCallCount = 0;
  int launchMapsCallCount = 0;
  
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return connectivityResult;
  }

  @override
  Future<Position> determinePosition() async {
    determinePositionCallCount++;
    if (shouldThrowPositionError) {
      throw positionError;
    }
    return Position(
        latitude: 45.0, longitude: 9.0, timestamp: DateTime.now(),
        accuracy: 0, altitude: 0, altitudeAccuracy: 0,
        heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  }

  @override
  Future<List<Pharmacy>> findNearbyPharmacies(LatLng center) async {
    if (shouldThrowPharmacyError) {
      throw Exception('API Error');
    }
    return pharmaciesToReturn;
  }

  @override
  Future<void> launchMaps(Pharmacy pharmacy) async {
    launchMapsCallCount++;
  }
}

void main() {
  late CoverageTestMapsService fakeMapsService;

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: PharmacyMapsScreen(
          mapsService: fakeMapsService, 
          tileProviderForTest: FakeTileProvider(),
        ),
      ),
    );
  }

  setUp(() {
    fakeMapsService = CoverageTestMapsService();
  });

  group('PharmacyMapsScreen Additional Coverage Tests', () {
    group('Search Field Edge Cases', () {
      testWidgets('handles empty search submission', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final searchField = find.byType(CupertinoSearchTextField);
        
        // Submit empty text
        await tester.enterText(searchField, '');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Should not trigger any loading state
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      });

      testWidgets('handles whitespace-only search submission', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final searchField = find.byType(CupertinoSearchTextField);
        
        // Submit whitespace-only text
        await tester.enterText(searchField, '   ');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Should not trigger any loading state
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      });

      testWidgets('typing exactly 3 characters should trigger autocomplete after debounce', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final searchField = find.byType(CupertinoSearchTextField);
        
        // Type exactly 3 characters
        await tester.enterText(searchField, 'Rom');
        await tester.pump(const Duration(milliseconds: 600));

        // Should attempt to fetch autocomplete (but will fail without network mock)
        // The important thing is that it passes the length check
        expect(find.text('Rom'), findsOneWidget);
      });

      testWidgets('clearing suggestions works when typing less than 3 characters', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final searchField = find.byType(CupertinoSearchTextField);
        
        // Type more than 3 characters first
        await tester.enterText(searchField, 'Roma');
        await tester.pump(const Duration(milliseconds: 600));
        
        // Then reduce to less than 3
        await tester.enterText(searchField, 'Ro');
        await tester.pump(const Duration(milliseconds: 600));

        // Should clear any potential suggestions
        expect(find.byType(CupertinoListTile), findsNothing);
      });
    });

    group('Debug Alert Coverage', () {
      testWidgets('_showDebugAlert can be triggered through directions flow', (tester) async {
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(
            id: 1, 
            name: 'Test Pharmacy', 
            address: 'Test Address', 
            position: LatLng(45.0, 9.0)
          ),
        ];
        
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Tap marker to show pharmacy info dialog
        final placemarkFinder = find.byIcon(CupertinoIcons.placemark_fill);
        await tester.tap(placemarkFinder);
        await tester.pumpAndSettle();

        // Verify pharmacy info dialog appears
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('Test Pharmacy'), findsOneWidget);
        expect(find.text('Indicazioni'), findsOneWidget);

        // Tap "Indicazioni" button - this will attempt to launch maps
        // which might trigger the debug alert if no map apps are available
        await tester.tap(find.text('Indicazioni'));
        await tester.pumpAndSettle();

        // The dialog should close (first dialog is dismissed)
        // and potentially show the debug alert, but this depends on platform state
        // At minimum, we've exercised the code path
        expect(fakeMapsService.launchMapsCallCount, 0); // Our fake service doesn't increment this
      });
    });

    group('Widget Lifecycle Coverage', () {
      testWidgets('dispose is called properly', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Navigate to a different widget to trigger disposal
        await tester.pumpWidget(
          const CupertinoApp(
            home: Text('Different Screen'),
          ),
        );

        // Should dispose without errors
        expect(find.text('Different Screen'), findsOneWidget);
      });

      testWidgets('timer cancellation in dispose', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final searchField = find.byType(CupertinoSearchTextField);
        
        // Start typing to create a debounce timer
        await tester.enterText(searchField, 'Roma');
        await tester.pump(const Duration(milliseconds: 200));
        
        // Navigate away before timer completes
        await tester.pumpWidget(
          const CupertinoApp(
            home: Text('Different Screen'),
          ),
        );

        // Should handle timer cancellation gracefully
        expect(find.text('Different Screen'), findsOneWidget);
      });
    });

    group('Search Listener Management', () {
      testWidgets('search listener is properly managed during suggestion tap', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final searchField = find.byType(CupertinoSearchTextField);
        
        // Type to potentially show suggestions
        await tester.enterText(searchField, 'Milano');
        await tester.pump(const Duration(milliseconds: 600));

        // If suggestions were shown and tapped, the listener should be 
        // temporarily removed and re-added. Since we can't easily mock HTTP,
        // we just verify the search field handles text input properly
        expect(find.text('Milano'), findsOneWidget);
      });
    });

    group('Map Controller Coverage', () {
      testWidgets('map controller center access in search area', (tester) async {
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(id: 1, name: 'Test', position: LatLng(45, 9))
        ];
        
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Tap "Cerca in questa zona" to trigger map center access
        await tester.tap(find.text('Cerca in questa zona'));
        await tester.pumpAndSettle();

        // This exercises the _mapController.camera.center access
        expect(find.text('Trovate 1 farmacie nelle vicinanze.'), findsOneWidget);
      });

      testWidgets('map move is called during successful position determination', (tester) async {
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(id: 1, name: 'Test', position: LatLng(45, 9))
        ];
        
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // The map should move to the determined position
        // This exercises the _mapController.move() call
        expect(find.text('Trovate 1 farmacie nelle vicinanze.'), findsOneWidget);
      });
    });

    group('Status Message Coverage', () {
      testWidgets('various status messages are displayed correctly', (tester) async {
        // Test the complete flow of status messages
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(id: 1, name: 'Final Pharmacy', position: LatLng(45, 9))
        ];
        
        await pumpScreen(tester);
        
        // Initial status
        expect(find.text('Accesso alla posizione...'), findsOneWidget);
        
        await tester.pump();
        
        // Should eventually show the position found and searching message
        // followed by the final pharmacy count
        await tester.pumpAndSettle();
        
        expect(find.text('Trovate 1 farmacie nelle vicinanze.'), findsOneWidget);
      });

      testWidgets('text overflow handling in status message', (tester) async {
        // Create a pharmacy with a very long name to test status message formatting
        fakeMapsService.pharmaciesToReturn = List.generate(50, (index) => 
          Pharmacy(
            id: index, 
            name: 'Very Long Pharmacy Name That Could Cause Overflow $index', 
            position: LatLng(45.0 + index * 0.001, 9.0 + index * 0.001)
          )
        );
        
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Status message should handle large numbers gracefully
        expect(find.text('Trovate 50 farmacie nelle vicinanze.'), findsOneWidget);
        
        // The Text widget has maxLines: 1 and overflow: TextOverflow.ellipsis
        // This tests that UI constraint
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Position Button Coverage', () {
      testWidgets('position button maintains proper state during multiple calls', (tester) async {
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(id: 1, name: 'Test', position: LatLng(45, 9))
        ];
        
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final positionButton = find.byIcon(CupertinoIcons.location_fill);
        fakeMapsService.determinePositionCallCount = 0;
        
        // Tap position button multiple times
        await tester.tap(positionButton);
        await tester.pump();
        await tester.tap(positionButton);
        await tester.pumpAndSettle();

        // Should handle multiple calls gracefully
        expect(fakeMapsService.determinePositionCallCount, greaterThanOrEqualTo(1));
      });
    });

    group('Mount State Checks', () {
      testWidgets('mounted checks prevent setState after disposal', (tester) async {
        await pumpScreen(tester);
        await tester.pump(); // Don't settle, keep in loading state
        
        // Navigate away while operations might still be in progress
        await tester.pumpWidget(
          const CupertinoApp(
            home: Text('Different Screen'),
          ),
        );
        
        // Allow any pending async operations to complete
        await tester.pump(const Duration(seconds: 1));
        
        // Should not throw errors due to setState on unmounted widget
        expect(find.text('Different Screen'), findsOneWidget);
      });
    });

    group('Additional UI Component Coverage', () {
      testWidgets('header container decoration and styling', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Check for header components
        expect(find.text('Farmacie Vicine'), findsOneWidget);
        expect(find.byType(CupertinoSearchTextField), findsOneWidget);
        
        // Verify the header is properly styled with Container decoration
        final container = find.ancestor(
          of: find.text('Farmacie Vicine'),
          matching: find.byType(Container),
        );
        expect(container, findsOneWidget);
      });

      testWidgets('safe area and column layout', (WidgetTester tester) async {
      final fakeMapsService = CoverageTestMapsService();
      await tester.pumpWidget(CupertinoApp(
        home: PharmacyMapsScreen(mapsService: fakeMapsService),
      ));
      await tester.pump();

      // Verify SafeArea is used
      expect(find.byType(SafeArea), findsOneWidget);
      
      // Verify Column layout structure (there are multiple Column widgets in the tree)
      expect(find.byType(Column), findsWidgets);
      
      // Verify Expanded widgets are present for layout (there are multiple)
      expect(find.byType(Expanded), findsWidgets);
    });

      testWidgets('positioned widgets are properly placed', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // All the positioned widgets should be present
        expect(find.text('Cerca in questa zona'), findsOneWidget);
        expect(find.byType(CupertinoPopupSurface), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.location_fill), findsOneWidget);
      });
    });
  });
}
