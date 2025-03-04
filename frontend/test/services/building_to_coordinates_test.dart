/// Tests for the GeocodingService, ensuring it correctly handles various scenarios related to geocoding addresses.
///
/// This test suite covers the following aspects:
///   - Verifies that the service throws an exception when the Google Maps API key is missing.
///   - Checks that the service returns `null` when an empty address is provided.
///   - Confirms that the service returns placeholder coordinates for the address "New Stop".
///   - Ensures that the service correctly retrieves and returns coordinates for a valid address.
///
/// The tests use `mockito` to mock the `HttpService` and `http.Client`, allowing for isolated unit testing
/// without making actual HTTP requests. The `flutter_dotenv` package is used to simulate loading
/// environment variables for the API key.
///
/// Example Usage:
/// ```dart
/// flutter test test/services/building_to_coordinates_test.dart
/// ```
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@GenerateMocks([HttpService, http.Client])
import 'building_to_coordinates_test.mocks.dart';

void main() {
  late MockHttpService mockHttpService;
  late MockClient mockClient;
  late GeocodingService geocodingService;

  setUp(() {
    mockHttpService = MockHttpService();
    mockClient = MockClient();
    when(mockHttpService.client).thenReturn(mockClient);
  });

  group('GeocodingService Tests', () {
    test('should throw exception if API key is missing', () {
      // Load dotenv with a fake key first
      dotenv.testLoad(fileInput: 'GOOGLE_PLACES_API_KEY=fake-api-key');

      // Now remove the key to simulate a missing key
      dotenv.env.remove('GOOGLE_PLACES_API_KEY');

      expect(() => GeocodingService(httpService: mockHttpService),
          throwsA(isA<Exception>()));
    });

    test('should return null if address is empty', () async {
      // Load dotenv with a fake key
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService = GeocodingService(
          httpService: mockHttpService, apiKey: "fake-api-key");
      final result = await geocodingService.getCoordinates('');
      expect(result, isNull);
    });

    test('should return placeholder coordinates for "New Stop"', () async {
      // Load dotenv with a fake key
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService = GeocodingService(
          httpService: mockHttpService, apiKey: "fake-api-key");
      final result = await geocodingService.getCoordinates('New Stop');
      expect(result, equals(const LatLng(45.5088, -73.5540)));
    });

    test('should return coordinates for valid address', () async {
      // Load dotenv with a fake key
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService = GeocodingService(
          httpService: mockHttpService, apiKey: "fake-api-key");
      final mockResponse = '''
      {
        "status": "OK",
        "results": [
          {
            "geometry": {
              "location": {
                "lat": 45.5017,
                "lng": -73.5673
              }
            }
          }
        ]
      }
      ''';

      when(mockClient.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/geocode/json?address=Montreal&key=fake-api-key")))
          .thenAnswer(
        (_) async => http.Response(mockResponse, 200),
      );

      final result = await geocodingService.getCoordinates('Montreal');
      expect(result, equals(const LatLng(45.5017, -73.5673)));
    });
    test('should return null on geocoding error', () async {
      final mockResponse = '''
  {
    "status": "OVER_QUERY_LIMIT",
    "results": []
  }
  ''';

      when(mockClient.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/geocode/json?address=InvalidAddress&key=fake-api-key")))
          .thenAnswer(
        (_) async => http.Response(mockResponse, 200),
      );

      final result = await geocodingService.getCoordinates('InvalidAddress');
      expect(result, isNull);
    });
  });
}
