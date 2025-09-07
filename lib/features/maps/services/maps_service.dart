import 'dart:convert';
import 'package:akora_app/features/maps/models/pharmacy_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter/foundation.dart';

// This is the "contract" or "interface" for our service.
// It defines WHAT the service can do, but not HOW it does it.
// The screen will only know about this abstract version.
abstract class IMapsService {
  Future<Position> determinePosition();
  Future<List<Pharmacy>> findNearbyPharmacies(latlng.LatLng center);
  Future<void> launchMaps(Pharmacy pharmacy);
  Future<List<ConnectivityResult>> checkConnectivity();
}

// This is the REAL implementation that the live app will use.
// It implements the contract and contains all the original plugin code.
class MapsService implements IMapsService {
  final http.Client _httpClient;

  // The real app will use this default constructor.
  MapsService() : _httpClient = http.Client();

  // The test will use this special constructor to inject fake client.
  @visibleForTesting
  MapsService.testable(this._httpClient);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() {
  // This is a direct call to the plugin.
  return Connectivity().checkConnectivity();
  }

  @override
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Instead of setState, we now throw an error that the screen can catch.
      return Future.error('I servizi di localizzazione sono disabilitati.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permesso di localizzazione negato.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permesso negato permanentemente. Abilitalo dalle impostazioni.');
    } 

    // On success, we return the Position object.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Future<List<Pharmacy>> findNearbyPharmacies(latlng.LatLng center) async {
  const radiusInMeters = 5000;
  final String query = """
    [out:json];
    (node["amenity"="pharmacy"](around:$radiusInMeters,${center.latitude},${center.longitude}););
    out center;
  """;
  final response = await _httpClient.post(
    Uri.parse('https://overpass-api.de/api/interpreter'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'data=$query',
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<Pharmacy> foundPharmacies = [];
    for (var element in (data['elements'] as List)) {
      final tags = element['tags'];
      if (tags != null && tags['name'] != null) {
        final street = tags['addr:street'] ?? '';
        final housenumber = tags['addr:housenumber'] ?? '';
        final city = tags['addr:city'] ?? '';
        final postcode = tags['addr:postcode'] ?? '';
        String fullAddress = [street, housenumber, postcode, city]
            .where((s) => s.isNotEmpty)
            .join(', ');

        foundPharmacies.add(Pharmacy(
          id: element['id'],
          name: tags['name'],
          position: latlng.LatLng(element['lat'], element['lon']),
          address: fullAddress.isNotEmpty ? fullAddress : null,
        ));
      }
    }
    return foundPharmacies; // Return the list on success
  } else {
    // Throw an error on failure
    throw Exception('Errore nel caricare le farmacie. Status Code: ${response.statusCode}, Body: ${response.body}');
  }

  }
  @override
  Future<void> launchMaps(Pharmacy pharmacy) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isNotEmpty) {
      await availableMaps.first.showDirections(
      destination: Coords(pharmacy.position.latitude, pharmacy.position.longitude),
      destinationTitle: pharmacy.name,
      );
    }
  }
}