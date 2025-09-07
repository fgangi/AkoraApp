// test/maps_service_test.dart
import 'package:akora_app/features/maps/models/pharmacy_model.dart';
import 'package:akora_app/features/maps/services/maps_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';     
import 'dart:typed_data';

// --- MANUAL FAKE HTTP CLIENT ---
class FakeHttpClient implements http.Client {
  String responseBody = '';
  int statusCode = 200;
  bool shouldThrowError = false;

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    if (shouldThrowError) {
      throw Exception('Fake network error');
    }
    return http.Response(responseBody, statusCode);
  }

  // We must provide empty placeholders for all other methods of http.Client
  // to satisfy the `implements` contract.
  @override
  void close() {}
  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async => http.Response('', 404);
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async => http.Response('', 404);
  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async => http.Response('', 404);
  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async => http.Response('', 404);
  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async => http.Response('', 404);
  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async => '';
  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async => Uint8List(0);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async => throw UnimplementedError('send');
}


void main() {
  late FakeHttpClient fakeHttpClient;
  late MapsService mapsService;

  setUp(() {
    fakeHttpClient = FakeHttpClient();
    // Use the testable constructor to inject our FAKE client.
    mapsService = MapsService.testable(fakeHttpClient);
  });

  group('findNearbyPharmacies', () {
    test('should return a list of pharmacies on a successful API call', () async {
      // Arrange
      // Create a fake JSON response that looks like the real API's response.
      final fakeJsonResponse = '''
      {
        "elements": [
          { "id": 1, "lat": 45.0, "lon": 9.0, "tags": { "name": "Farmacia Test 1" } }
        ]
      }
      ''';
      
      fakeHttpClient.responseBody = fakeJsonResponse;
      fakeHttpClient.statusCode = 200;

      // Act
      final pharmacies = await mapsService.findNearbyPharmacies(const LatLng(0, 0));

      // Assert
      expect(pharmacies, isA<List<Pharmacy>>());
      expect(pharmacies.length, 1);
      expect(pharmacies.first.name, 'Farmacia Test 1');
    });

    test('should throw an exception on a failed API call (e.g., 500)', () async {
      // Arrange
      // 1. Configure to return a server error.
      fakeHttpClient.responseBody = 'Internal Server Error';
      fakeHttpClient.statusCode = 500;

      // Act
      final call = mapsService.findNearbyPharmacies;

      // Assert
      // We expect the method to throw an Exception when the fake client returns a non-200 status code.
      expect(() => call(const LatLng(0, 0)), throwsA(isA<Exception>()));
    });
  });
}