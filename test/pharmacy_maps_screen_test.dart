// test/pharmacy_maps_screen_test.dart

import 'package:akora_app/features/maps/models/pharmacy_model.dart';
import 'package:akora_app/features/maps/screens/pharmacy_maps_screen.dart';
import 'package:akora_app/features/maps/services/maps_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';

// This is a fake TileProvider that provides a blank, transparent image.
// It prevents flutter_map from making real network requests during tests.
/*class FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(Coords<num> coords, TileLayer options) {
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
}*/

// --- MANUAL FAKE/MOCK CLASS ---
class FakeMapsService implements IMapsService {
  bool shouldThrowPositionError = false;
  String positionError = 'Permission Denied';
  bool shouldThrowPharmacyError = false;
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
        home: PharmacyMapsScreen(mapsService: fakeMapsService),
      ),
    );
  }

  setUp(() {
    fakeMapsService = FakeMapsService();
  });

  group('PharmacyMapsScreen', () {
    // --- TEST CASE 1: Successful Load Path (Corrected for Race Condition) ---
    /*testWidgets('should show loading, then pharmacies on successful load',
        (tester) async {
      // Arrange:
      // Configure our fake service to return successful data.
      fakeMapsService.pharmaciesToReturn = [
        Pharmacy(id: 1, name: 'Farmacia 1', position: LatLng(45.0, 9.0)),
        Pharmacy(id: 2, name: 'Farmacia 2', position: LatLng(45.01, 9.01)),
      ];
      
      // --- ACT & ASSERT (Part 1: Initial State) ---
      await pumpScreen(tester);
      
      // At this exact moment, only the FIRST frame has rendered.
      // The async work inside initState has started but not yet completed.
      // This is the correct time to check for the initial loading message.
      expect(find.text('Accesso alla posizione...'), findsOneWidget);
      
      // --- ACT & ASSERT (Part 2: Final State) ---
      // NOW, we let all the fake Futures from our service complete and
      // allow the UI to rebuild and settle into its final state.
      await tester.pumpAndSettle();

      // The screen should have rebuilt with the final data from the fake service.
      expect(find.text('Trovate 2 farmacie nelle vicinanze.'), findsOneWidget);
      // The initial message should now be gone.
      expect(find.text('Accesso alla posizione...'), findsNothing);
      
      expect(find.byType(Marker), findsNWidgets(2));
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });*/

    testWidgets('should show error message when location permission is denied',
        (tester) async {
      // Arrange:
      // Configure our fake service to throw a position error.
      fakeMapsService.shouldThrowPositionError = true;
      fakeMapsService.positionError = 'Permesso di localizzazione negato.';

      // Act:
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      // Assert:
      // The screen should display the error thrown by our fake service.
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
  });
}