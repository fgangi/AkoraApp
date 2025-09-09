// test/maps_service_integration_test.dart
import 'package:akora_app/features/maps/services/maps_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'dart:typed_data';

/// More sophisticated mock for HTTP client that can track requests
class MockHttpClient implements http.Client {
  final List<http.Request> capturedRequests = [];
  String responseBody = '';
  int statusCode = 200;
  bool shouldThrowError = false;
  Map<String, String> responseHeaders = {};

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    // Capture the request for verification
    final request = http.Request('POST', url);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.body = body.toString();
    capturedRequests.add(request);

    if (shouldThrowError) {
      throw Exception('Mock network error');
    }
    return http.Response(responseBody, statusCode, headers: responseHeaders);
  }

  void reset() {
    capturedRequests.clear();
    responseBody = '';
    statusCode = 200;
    shouldThrowError = false;
    responseHeaders.clear();
  }

  // Implement required methods with defaults
  @override
  void close() {}
  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async => 
    http.Response('', 404);
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async => 
    http.Response('', 404);
  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async => 
    http.Response('', 404);
  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async => 
    http.Response('', 404);
  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async => 
    http.Response('', 404);
  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async => '';
  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async => Uint8List(0);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async => 
    throw UnimplementedError('send');
}

void main() {
  late MockHttpClient mockHttpClient;
  late MapsService mapsService;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mapsService = MapsService.testable(mockHttpClient);
  });

  group('MapsService Integration Tests', () {
    group('API Request Construction', () {
      test('constructs correct Overpass API request', () async {
        // Arrange
        const center = LatLng(45.464, 9.190);
        const expectedRadius = 5000;
        
        mockHttpClient.responseBody = '{"elements": []}';
        mockHttpClient.statusCode = 200;

        // Act
        await mapsService.findNearbyPharmacies(center);

        // Assert
        expect(mockHttpClient.capturedRequests.length, 1);
        
        final request = mockHttpClient.capturedRequests.first;
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://overpass-api.de/api/interpreter');
        expect(request.headers['Content-Type'], startsWith('application/x-www-form-urlencoded'));
        
        // Verify the query contains the right location and radius
        expect(request.body, contains('45.464'));
        expect(request.body, contains('9.19')); // Floating point precision may vary
        expect(request.body, contains('$expectedRadius'));
        expect(request.body, contains('amenity'));
        expect(request.body, contains('pharmacy'));
      });

      test('includes all required Overpass query elements', () async {
        // Arrange
        mockHttpClient.responseBody = '{"elements": []}';
        
        // Act
        await mapsService.findNearbyPharmacies(const LatLng(0, 0));

        // Assert
        final request = mockHttpClient.capturedRequests.first;
        final queryData = request.body;
        
        // Check for Overpass QL syntax elements
        expect(queryData, contains('[out:json]'));
        expect(queryData, contains('node'));
        expect(queryData, contains('around:'));
        expect(queryData, contains('out center'));
      });
    });

    group('Response Parsing Edge Cases', () {
      test('handles response with mixed valid and invalid elements', () async {
        // Arrange
        final complexResponse = '''
        {
          "elements": [
            {
              "id": 1,
              "lat": 45.1,
              "lon": 9.1,
              "tags": {
                "name": "Farmacia Valida",
                "addr:street": "Via Roma",
                "addr:housenumber": "123"
              }
            },
            {
              "id": 2,
              "lat": 45.2,
              "lon": 9.2,
              "tags": null
            },
            {
              "id": 3,
              "lat": 45.3,
              "lon": 9.3,
              "tags": {
                "amenity": "pharmacy"
              }
            },
            {
              "id": 4,
              "lat": 45.4,
              "lon": 9.4,
              "tags": {
                "name": "Farmacia Completa",
                "addr:street": "Via Milano",
                "addr:housenumber": "456",
                "addr:postcode": "20100",
                "addr:city": "Milano"
              }
            }
          ]
        }
        ''';
        
        mockHttpClient.responseBody = complexResponse;

        // Act
        final pharmacies = await mapsService.findNearbyPharmacies(const LatLng(0, 0));

        // Assert
        expect(pharmacies.length, 2); // Only elements with names
        
        final firstPharmacy = pharmacies.firstWhere((p) => p.id == 1);
        expect(firstPharmacy.name, 'Farmacia Valida');
        expect(firstPharmacy.address, 'Via Roma, 123');
        
        final secondPharmacy = pharmacies.firstWhere((p) => p.id == 4);
        expect(secondPharmacy.name, 'Farmacia Completa');
        expect(secondPharmacy.address, 'Via Milano, 456, 20100, Milano');
      });

      test('handles response with special characters in names and addresses', () async {
        // Arrange
        final specialCharResponse = '''
        {
          "elements": [
            {
              "id": 100,
              "lat": 45.0,
              "lon": 9.0,
              "tags": {
                "name": "Farmacia Sant'Antonio",
                "addr:street": "Via dell'Università",
                "addr:housenumber": "1/B"
              }
            }
          ]
        }
        ''';
        
        mockHttpClient.responseBody = specialCharResponse;

        // Act
        final pharmacies = await mapsService.findNearbyPharmacies(const LatLng(0, 0));

        // Assert
        expect(pharmacies.length, 1);
        expect(pharmacies.first.name, "Farmacia Sant'Antonio");
        expect(pharmacies.first.address, "Via dell'Università, 1/B");
      });

      test('handles large response with many pharmacies', () async {
        // Arrange
        final elements = List.generate(50, (index) => '''
          {
            "id": $index,
            "lat": ${45.0 + index * 0.001},
            "lon": ${9.0 + index * 0.001},
            "tags": {
              "name": "Farmacia $index"
            }
          }
        ''').join(',');
        
        final largeResponse = '''
        {
          "elements": [$elements]
        }
        ''';
        
        mockHttpClient.responseBody = largeResponse;

        // Act
        final pharmacies = await mapsService.findNearbyPharmacies(const LatLng(0, 0));

        // Assert
        expect(pharmacies.length, 50);
        expect(pharmacies.first.name, 'Farmacia 0');
        expect(pharmacies.last.name, 'Farmacia 49');
      });
    });

    group('Error Handling Scenarios', () {
      test('handles timeout scenarios gracefully', () async {
        // Arrange
        mockHttpClient.shouldThrowError = true;

        // Act & Assert
        expect(
          () => mapsService.findNearbyPharmacies(const LatLng(0, 0)),
          throwsA(isA<Exception>()),
        );
      });

      test('handles different content types in error responses', () async {
        // Arrange
        mockHttpClient.statusCode = 500;
        mockHttpClient.responseBody = '<html><body>Internal Server Error</body></html>';
        mockHttpClient.responseHeaders = {'content-type': 'text/html'};

        // Act & Assert
        expect(
          () => mapsService.findNearbyPharmacies(const LatLng(0, 0)),
          throwsA(isA<Exception>()),
        );
      });

      test('handles rate limiting (429) responses', () async {
        // Arrange
        mockHttpClient.statusCode = 429;
        mockHttpClient.responseBody = 'Too Many Requests';

        // Act & Assert
        expect(
          () => mapsService.findNearbyPharmacies(const LatLng(0, 0)),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Performance and Optimization', () {
      test('makes only one HTTP request per call', () async {
        // Arrange
        mockHttpClient.responseBody = '{"elements": []}';

        // Act
        await mapsService.findNearbyPharmacies(const LatLng(0, 0));

        // Assert
        expect(mockHttpClient.capturedRequests.length, 1);
      });

      test('handles concurrent requests correctly', () async {
        // Arrange
        mockHttpClient.responseBody = '{"elements": []}';

        // Act
        final futures = List.generate(3, (index) => 
          mapsService.findNearbyPharmacies(LatLng(45.0 + index, 9.0 + index))
        );
        
        final results = await Future.wait(futures);

        // Assert
        expect(results.length, 3);
        expect(mockHttpClient.capturedRequests.length, 3);
        
        // Verify each request has different coordinates
        final requests = mockHttpClient.capturedRequests;
        expect(requests[0].body, contains('45.0'));
        expect(requests[1].body, contains('46.0'));
        expect(requests[2].body, contains('47.0'));
      });
    });
  });
}
