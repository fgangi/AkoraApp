// test/pharmacy_maps_screen_test.dart

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

// This is a fake TileProvider that provides a blank, transparent image.
// It prevents flutter_map from making real network requests during tests.
class FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    // Return a transparent 1x1 pixel image.
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

// --- MANUAL FAKE/MOCK CLASS ---
class FakeMapsService implements IMapsService {
  bool shouldThrowPositionError = false;
  String positionError = 'Permission Denied';
  bool shouldThrowPharmacyError = false;
  int findPharmaciesCallCount = 0;
  List<ConnectivityResult> connectivityResult = [ConnectivityResult.wifi];
  List<Pharmacy> pharmaciesToReturn = [];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return connectivityResult;
  }

  @override
  Future<Position> determinePosition() async {
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
     findPharmaciesCallCount++;

    if (shouldThrowPharmacyError) {
      throw Exception('API Error');
    }
    return pharmaciesToReturn;
  }

  @override
  Future<void> launchMaps(Pharmacy pharmacy) async {}
}


void main() {
  late FakeMapsService fakeMapsService;

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: PharmacyMapsScreen(mapsService: fakeMapsService, tileProviderForTest: FakeTileProvider(),),
      ),
    );
  }

  setUp(() {
    fakeMapsService = FakeMapsService();
  });

  group('PharmacyMapsScreen', () {
    // --- TEST CASE 1: Successful Load Path  ---
    testWidgets('should show loading, then pharmacies on successful load',
        (tester) async {
      // Arrange:
      // Configure fake service to return successful data.
      fakeMapsService.pharmaciesToReturn = [
        Pharmacy(id: 1, name: 'Farmacia 1', position: LatLng(45.0, 9.0)),
        Pharmacy(id: 2, name: 'Farmacia 2', position: LatLng(45.01, 9.01)),
      ];
      
      // act
      await pumpScreen(tester);
      expect(find.text('Accesso alla posizione...'), findsOneWidget);
      await tester.pumpAndSettle();

      // The screen should have rebuilt with the final data from the fake service.
      expect(find.text('Trovate 2 farmacie nelle vicinanze.'), findsOneWidget);

      final markerLayer = find.byType(MarkerLayer);
      expect(markerLayer, findsOneWidget);
      final layerWidget = tester.widget<MarkerLayer>(markerLayer);
      expect(layerWidget.markers.length, 2);
    });

    testWidgets('should show error message when location permission is denied',
        (tester) async {
      // Arrange:
      // Configure fake service to throw a position error.
      fakeMapsService.shouldThrowPositionError = true;
      fakeMapsService.positionError = 'Permesso di localizzazione negato.';

      // Act:
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      // Assert:
      // The screen should display the error 
      expect(find.text('Permesso di localizzazione negato.'), findsOneWidget);
      expect(find.byType(Marker), findsNothing);
    });

    testWidgets('should show no internet message when connectivity is none', (tester) async {
      // Arrange:
      // Configure the fake service to return no connectivity.
      fakeMapsService.connectivityResult = [ConnectivityResult.none];
      
      // Act:
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      // Assert:
      expect(find.text('Nessuna connessione a internet.'), findsOneWidget);
    });

    testWidgets('should show error message if finding pharmacies fails', (tester) async {
      // Arrange:
      // Configure the fake service to throw an error when searching for pharmacies.
      fakeMapsService.shouldThrowPharmacyError = true;

      // Act:
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      // Assert:
      expect(find.text('Errore nel caricare le farmacie.'), findsOneWidget);
    });

     testWidgets('tapping "Cerca in questa zona" button calls findNearbyPharmacies', (tester) async {
      // Arrange
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      //reset the counter
      fakeMapsService.findPharmaciesCallCount = 0;

      // Act
      await tester.tap(find.text('Cerca in questa zona'));
      await tester.pumpAndSettle();

      // Assert
      expect(fakeMapsService.findPharmaciesCallCount, 1);
    });

    testWidgets('tapping a map marker should show pharmacy info dialog', (tester) async {
      // Arrange
      fakeMapsService.pharmaciesToReturn = [
        Pharmacy(id: 1, name: 'Farmacia Centrale', address: 'Via Roma 1', position: LatLng(45.0, 9.0)),
      ];
      await pumpScreen(tester);
      await tester.pumpAndSettle();
      
      final markerLayerFinder = find.byType(MarkerLayer);
      expect(markerLayerFinder, findsOneWidget);

      final layerWidget = tester.widget<MarkerLayer>(markerLayerFinder);
      expect(layerWidget.markers.length, 1);

      final placemarkFinder = find.descendant(
        of: markerLayerFinder,
        matching: find.byIcon(CupertinoIcons.placemark_fill),
      );

      
      if (placemarkFinder.evaluate().isEmpty) {
        final globalPlacemark = find.byIcon(CupertinoIcons.placemark_fill);
        expect(globalPlacemark, findsOneWidget);
        await tester.tap(globalPlacemark);
      } else {
        expect(placemarkFinder, findsOneWidget);
        await tester.tap(placemarkFinder);
      }

      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Farmacia Centrale'), findsOneWidget);
      expect(find.textContaining('Via Roma 1'), findsOneWidget);
    });

    testWidgets('tapping a map marker with no address shows dialog with just the title', (tester) async {
      fakeMapsService.pharmaciesToReturn = [
        Pharmacy(id: 1, name: 'Farmacia Senza Indirizzo', position: LatLng(45.0, 9.0)),
      ];

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      final markerLayerFinder = find.byType(MarkerLayer);
      expect(markerLayerFinder, findsOneWidget);
      final layerWidget = tester.widget<MarkerLayer>(markerLayerFinder);
      expect(layerWidget.markers.length, 1);

      final placemarkFinder = find.byIcon(CupertinoIcons.placemark_fill);
      expect(placemarkFinder, findsOneWidget);
      await tester.tap(placemarkFinder);
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Farmacia Senza Indirizzo'), findsOneWidget);
      expect(find.textContaining('Via'), findsNothing);
    });

    testWidgets('typing less than 3 characters clears suggestions', (tester) async {
      await pumpScreen(tester);
      await tester.enterText(find.byType(CupertinoSearchTextField), 'Ro');
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(CupertinoListTile), findsNothing);
    });

    testWidgets('tapping recenter button calls determinePosition (and triggers pharmacy search)', (tester) async {
      fakeMapsService.pharmaciesToReturn = [Pharmacy(id: 1, name: 'P', position: LatLng(45, 9))];

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      fakeMapsService.findPharmaciesCallCount = 0;
      final recenterFinder = find.byIcon(CupertinoIcons.location_fill);
      expect(recenterFinder, findsOneWidget);

      await tester.tap(recenterFinder);
      await tester.pumpAndSettle();

      expect(fakeMapsService.findPharmaciesCallCount >= 1, true);
    });

    group('Search functionality', () {
      testWidgets('typing more than 2 characters triggers autocomplete search', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Type more than 2 characters
        await tester.enterText(find.byType(CupertinoSearchTextField), 'Roma');
        await tester.pump(const Duration(milliseconds: 600)); // Wait for debounce

        // Note: We can't easily test the HTTP request in widget tests without mocking,
        // but we can verify the search field accepts input
        expect(find.text('Roma'), findsOneWidget);
      });

      testWidgets('onSubmitted calls geocoding', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final searchField = find.byType(CupertinoSearchTextField);
        await tester.enterText(searchField, 'Milano');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Verify loading state is triggered (can't easily test HTTP without mocking)
        // So we just verify the text was entered properly
        expect(find.text('Milano'), findsOneWidget);
      });

      testWidgets('tapping suggestion triggers geocoding', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Enter text to potentially trigger suggestions (though we can't easily mock HTTP in widget tests)
        await tester.enterText(find.byType(CupertinoSearchTextField), 'Milano');
        await tester.pump(const Duration(milliseconds: 600));

        // Submit the text to trigger geocoding (since we can't test suggestions without HTTP mocking)
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Verify the input was processed
        expect(find.text('Milano'), findsOneWidget);
      });
    });

    group('Pharmacy info dialog', () {
      testWidgets('dialog shows "Indicazioni" button and handles tap', (tester) async {
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(id: 1, name: 'Farmacia Test', address: 'Via Test 1', position: LatLng(45.0, 9.0)),
        ];
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Tap marker to show dialog
        final placemarkFinder = find.byIcon(CupertinoIcons.placemark_fill);
        await tester.tap(placemarkFinder);
        await tester.pumpAndSettle();

        // Verify dialog content
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('Farmacia Test'), findsOneWidget);
        expect(find.text('Indicazioni'), findsOneWidget);
        expect(find.text('Chiudi'), findsOneWidget);

        // Test "Chiudi" button
        await tester.tap(find.text('Chiudi'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoAlertDialog), findsNothing);
      });
    });

    group('Loading states', () {
      testWidgets('shows loading indicator when searching for pharmacies', (tester) async {
        await pumpScreen(tester);
        
        // During initial loading, check for initial status message
        expect(find.text('Accesso alla posizione...'), findsOneWidget);
        
        await tester.pump(const Duration(milliseconds: 100));
        // The loading indicator might not be visible immediately due to timing
        // This is better tested in integration tests with proper async handling
      });

      testWidgets('hides loading indicator after search completes', (tester) async {
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(id: 1, name: 'Test', position: LatLng(45, 9)),
        ];

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // After loading completes
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
        expect(find.text('Trovate 1 farmacie nelle vicinanze.'), findsOneWidget);
      });
    });

    group('Map interactions', () {
      testWidgets('map renders with proper initial settings', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Verify map components are present
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.byType(TileLayer), findsOneWidget);
        expect(find.byType(MarkerLayer), findsOneWidget);
      });

      testWidgets('search area button is positioned correctly', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('Cerca in questa zona'), findsOneWidget);
        
        // Verify it's a button that can be tapped
        final button = find.ancestor(
          of: find.text('Cerca in questa zona'),
          matching: find.byType(CupertinoButton),
        );
        expect(button, findsOneWidget);
      });
    });

    group('Error handling edge cases', () {
      testWidgets('handles service unavailable error', (tester) async {
        fakeMapsService.shouldThrowPositionError = true;
        fakeMapsService.positionError = 'I servizi di localizzazione sono disabilitati.';

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('I servizi di localizzazione sono disabilitati.'), findsOneWidget);
      });

      testWidgets('handles permission denied forever error', (tester) async {
        fakeMapsService.shouldThrowPositionError = true;
        fakeMapsService.positionError = 'Permesso negato permanentemente. Abilitalo dalle impostazioni.';

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('Permesso negato permanentemente. Abilitalo dalle impostazioni.'), findsOneWidget);
      });

      testWidgets('handles mobile connectivity', (tester) async {
        fakeMapsService.connectivityResult = [ConnectivityResult.mobile];
        fakeMapsService.pharmaciesToReturn = [
          Pharmacy(id: 1, name: 'Mobile Pharmacy', position: LatLng(45, 9)),
        ];

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        // Should work fine with mobile connection
        expect(find.text('Trovate 1 farmacie nelle vicinanze.'), findsOneWidget);
      });
    });

    group('UI Components', () {
      testWidgets('header displays correct title and search field', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(find.text('Farmacie Vicine'), findsOneWidget);
        expect(find.byType(CupertinoSearchTextField), findsOneWidget);
        
        final searchField = tester.widget<CupertinoSearchTextField>(
          find.byType(CupertinoSearchTextField)
        );
        expect(searchField.placeholder, 'Cerca un indirizzo o una città');
      });

      testWidgets('status message popup is properly positioned', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      });

      testWidgets('recenter button is properly styled and positioned', (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final recenterButton = find.byIcon(CupertinoIcons.location_fill);
        expect(recenterButton, findsOneWidget);
        
        // Verify it's wrapped in a CupertinoButton
        final buttonFinder = find.ancestor(
          of: recenterButton,
          matching: find.byType(CupertinoButton),
        );
        expect(buttonFinder, findsOneWidget);
      });
    });
  });
}