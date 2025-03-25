import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';

import 'google_poi_service_test.mocks.dart';

/// Generate a mock class for IHttpClient
@GenerateNiceMocks([MockSpec<IHttpClient>()])
void main() {
  late MockIHttpClient mockHttpClient;
  late GooglePOIService poiService;

  const mockApiKey = 'test-api-key';

  setUp(() {
    mockHttpClient = MockIHttpClient();
    poiService =
        GooglePOIService(apiKey: mockApiKey, httpClient: mockHttpClient);
  });

  group('GooglePOIService Tests', () {
    test('should parse all fields from full API response accurately', () async {
      final mockJsonResponse = {
        "html_attributions": [],
        "results": [
          {
            "business_status": "OPERATIONAL",
            "geometry": {
              "location": {"lat": 43.6383548, "lng": -79.3801917},
            },
            "icon":
                "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/bar-71.png",
            "name": "The Goodman Pub and Kitchen",
            "opening_hours": {"open_now": false},
            "photos": [
              {"photo_reference": "PHOTO_REF_1"}
            ],
            "place_id": "PLACE_ID_1",
            "plus_code": {
              "compound_code": "JJQ9+8W Toronto, ON, Canada",
            },
            "price_level": 2,
            "rating": 4.1,
            "types": ["bar", "restaurant", "food"],
            "user_ratings_total": 3050,
            "vicinity": "207 Queens Quay West, Toronto"
          },
          {
            "business_status": "OPERATIONAL",
            "geometry": {
              "location": {"lat": 43.6382488, "lng": -79.3804212},
            },
            "icon":
                "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png",
            "name": "Joe Bird",
            "opening_hours": {"open_now": false},
            "photos": [
              {"photo_reference": "PHOTO_REF_2"}
            ],
            "place_id": "PLACE_ID_2",
            "plus_code": {
              "compound_code": "JJQ9+7R Toronto, ON, Canada",
            },
            "price_level": 2,
            "rating": 4.1,
            "types": ["restaurant", "store", "food"],
            "user_ratings_total": 1470,
            "vicinity": "#150, 207 Queens Quay West, Toronto"
          }
        ],
        "status": "OK"
      };

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockJsonResponse), 200),
      );

      final places = await poiService.getNearbyPlaces(
        latitude: 43.6383,
        longitude: -79.3801,
        type: 'restaurant',
        radius: 500,
      );

      expect(places.length, 2);

      final first = places[0];
      expect(first.name, 'The Goodman Pub and Kitchen');
      expect(first.placeId, 'PLACE_ID_1');
      expect(first.latitude, 43.6383548);
      expect(first.longitude, -79.3801917);
      expect(first.rating, 4.1);
      expect(first.priceLevel, 2);
      expect(first.openNow, false);
      expect(first.photoReference, 'PHOTO_REF_1');
      expect(first.address, '207 Queens Quay West, Toronto');
      expect(first.types, containsAll(['bar', 'restaurant', 'food']));
      expect(first.plusCode, 'JJQ9+8W Toronto, ON, Canada');
      expect(first.iconUrl,
          'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/bar-71.png');
    });

    test('should throw Exception when HTTP status code is not 200', () async {
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      expect(
        () => poiService.getNearbyPlaces(
          latitude: 43.6383,
          longitude: -79.3801,
          type: 'restaurant',
          radius: 500,
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Failed to fetch nearby places: 500'))),
      );
    });

    test('should throw Exception when Google Places API status is not OK',
        () async {
      final errorResponse = {
        "status": "REQUEST_DENIED",
        "error_message": "Invalid API key"
      };

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(errorResponse), 200),
      );

      expect(
        () => poiService.getNearbyPlaces(
          latitude: 43.6383,
          longitude: -79.3801,
          type: 'restaurant',
          radius: 500,
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Google Places API Error: REQUEST_DENIED'))),
      );
    });

    test('should throw Exception on network failure', () async {
      when(mockHttpClient.get(any)).thenThrow(Exception('Network Error'));

      expect(
        () => poiService.getNearbyPlaces(
          latitude: 43.6383,
          longitude: -79.3801,
          type: 'restaurant',
          radius: 500,
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Error fetching nearby places:'))),
      );
    });

    test('should throw Exception on invalid JSON response', () async {
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('INVALID_JSON', 200),
      );

      expect(
        () => poiService.getNearbyPlaces(
          latitude: 43.6383,
          longitude: -79.3801,
          type: 'restaurant',
          radius: 500,
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Error fetching nearby places:'))),
      );
    });
  });
}
