import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/services/geocoding_service.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@GenerateMocks([IHttpClient])
import 'geocoding_service_test.mocks.dart';

void main() {
  late MockIHttpClient mockHttpClient;
  late GeocodingService geocodingService;

  setUp(() {
    mockHttpClient = MockIHttpClient();
  });

  group('GeocodingService Tests', () {
    test('should throw exception if API key is missing', () {
      dotenv.testLoad(fileInput: ''); // No API key
      expect(() => GeocodingService(httpClient: mockHttpClient),
          throwsA(isA<Exception>()));
    });

    test('should return null if address is empty', () async {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService =
          GeocodingService(httpClient: mockHttpClient, apiKey: "fake-api-key");
      final result = await geocodingService.getCoordinates('');
      expect(result, isNull);
    });

    test('should return placeholder coordinates for "New Stop"', () async {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService =
          GeocodingService(httpClient: mockHttpClient, apiKey: "fake-api-key");
      final result = await geocodingService.getCoordinates('New Stop');
      expect(result, equals(const LatLng(45.5088, -73.5540)));
    });

    test('should return coordinates for valid address', () async {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService =
          GeocodingService(httpClient: mockHttpClient, apiKey: "fake-api-key");

      final mockResponseBody = jsonEncode({
        "status": "OK",
        "results": [
          {
            "geometry": {
              "location": {"lat": 45.5017, "lng": -73.5673}
            }
          }
        ]
      });

      when(mockHttpClient.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=Montreal&key=fake-api-key",
      ))).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      final result = await geocodingService.getCoordinates('Montreal');
      expect(result, equals(const LatLng(45.5017, -73.5673)));
    });

    test('should return null on geocoding API error', () async {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService =
          GeocodingService(httpClient: mockHttpClient, apiKey: "fake-api-key");

      final mockResponseBody =
          jsonEncode({"status": "OVER_QUERY_LIMIT", "results": []});

      when(mockHttpClient.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?address=InvalidAddress&key=fake-api-key",
      ))).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      final result = await geocodingService.getCoordinates('InvalidAddress');
      expect(result, isNull);
    });
    test('should return null when httpClient throws an exception', () async {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=fake-api-key');
      geocodingService =
          GeocodingService(httpClient: mockHttpClient, apiKey: "fake-api-key");

      when(mockHttpClient.get(any)).thenThrow(Exception('Network error'));

      final result = await geocodingService.getCoordinates('Somewhere');
      expect(result, isNull);
    });
  });
}
