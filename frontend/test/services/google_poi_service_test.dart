import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:http/http.dart' as http;

import 'google_poi_service_test.mocks.dart';

/// Generates mock classes for [HttpService] and [http.Client] using Mockito
@GenerateNiceMocks([MockSpec<HttpService>(), MockSpec<http.Client>()])
void main() {
  // Declare variables for mock dependencies and service instance
  late MockHttpService mockHttpService;
  late MockClient mockHttpClient;
  late GooglePOIService poiService;
  const mockApiKey = 'test-api-key';

  /// Set up fresh mocks and service instance before each test
  setUp(() {
    mockHttpService = MockHttpService();
    mockHttpClient = MockClient();
    when(mockHttpService.client).thenReturn(mockHttpClient);
    poiService =
        GooglePOIService(apiKey: mockApiKey, httpService: mockHttpService);
  });

  /// Group containing all tests for [GooglePOIService]
  group('GooglePOIService Tests', () {
    /// Test case to verify correct parsing of all fields from a complete and valid API response
    test('should parse all fields from full API response accurately', () async {
      // Mock JSON response simulating a valid Google Places API response with two POIs
      final mockJsonResponse = {
        "html_attributions": [],
        "results": [
          {
            "business_status": "OPERATIONAL",
            "geometry": {
              "location": {"lat": 43.63835479999999, "lng": -79.3801917},
              "viewport": {
                "northeast": {"lat": 43.64004403029149, "lng": -79.37912355},
                "southwest": {
                  "lat": 43.63734606970849,
                  "lng": -79.38191854999999
                }
              }
            },
            "icon":
                "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/bar-71.png",
            "icon_background_color": "#FF9E67",
            "icon_mask_base_uri":
                "https://maps.gstatic.com/place_api/icons/v2/bar_pinlet",
            "name": "The Goodman Pub and Kitchen",
            "opening_hours": {"open_now": false},
            "photos": [
              {
                "height": 3201,
                "html_attributions": [],
                "photo_reference": "PHOTO_REF_1",
                "width": 4801
              }
            ],
            "place_id": "PLACE_ID_1",
            "plus_code": {
              "compound_code": "JJQ9+8W Toronto, ON, Canada",
              "global_code": "87M2JJQ9+8W"
            },
            "price_level": 2,
            "rating": 4.1,
            "reference": "PLACE_ID_1",
            "scope": "GOOGLE",
            "types": [
              "bar",
              "restaurant",
              "point_of_interest",
              "food",
              "establishment"
            ],
            "user_ratings_total": 3050,
            "vicinity": "207 Queens Quay West, Toronto"
          },
          {
            "business_status": "OPERATIONAL",
            "geometry": {
              "location": {"lat": 43.63824880000001, "lng": -79.3804212},
              "viewport": {
                "northeast": {
                  "lat": 43.6398915802915,
                  "lng": -79.37939771970849
                },
                "southwest": {"lat": 43.6371936197085, "lng": -79.3820956802915}
              }
            },
            "icon":
                "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/restaurant-71.png",
            "icon_background_color": "#FF9E67",
            "icon_mask_base_uri":
                "https://maps.gstatic.com/place_api/icons/v2/restaurant_pinlet",
            "name": "Joe Bird",
            "opening_hours": {"open_now": false},
            "photos": [
              {
                "height": 563,
                "html_attributions": [],
                "photo_reference": "PHOTO_REF_2",
                "width": 1000
              }
            ],
            "place_id": "PLACE_ID_2",
            "plus_code": {
              "compound_code": "JJQ9+7R Toronto, ON, Canada",
              "global_code": "87M2JJQ9+7R"
            },
            "price_level": 2,
            "rating": 4.1,
            "reference": "PLACE_ID_2",
            "scope": "GOOGLE",
            "types": [
              "restaurant",
              "point_of_interest",
              "store",
              "food",
              "establishment"
            ],
            "user_ratings_total": 1470,
            "vicinity": "#150, 207 Queens Quay West, Toronto"
          }
        ],
        "status": "OK"
      };

      // Simulate successful HTTP response with mock data
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockJsonResponse), 200),
      );

      // Call the method under test
      final places = await poiService.getNearbyPlaces(
        latitude: 43.6383,
        longitude: -79.3801,
        type: 'restaurant',
        radius: 500,
      );

      // Assert that two places were returned and all fields are correctly parsed
      expect(places.length, 2);

      final firstPlace = places[0];
      expect(firstPlace.name, 'The Goodman Pub and Kitchen');
      expect(firstPlace.placeId, 'PLACE_ID_1');
      expect(firstPlace.latitude, 43.63835479999999);
      expect(firstPlace.longitude, -79.3801917);
      expect(firstPlace.rating, 4.1);
      expect(firstPlace.priceLevel, 2);
      expect(firstPlace.openNow, false);
      expect(firstPlace.photoReference, 'PHOTO_REF_1');
      expect(firstPlace.address, '207 Queens Quay West, Toronto');
      expect(firstPlace.types, containsAll(['bar', 'restaurant', 'food']));
      expect(firstPlace.plusCode, 'JJQ9+8W Toronto, ON, Canada');
      expect(firstPlace.iconUrl,
          'https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/bar-71.png');

      final secondPlace = places[1];
      expect(secondPlace.name, 'Joe Bird');
      expect(secondPlace.placeId, 'PLACE_ID_2');
      expect(secondPlace.photoReference, 'PHOTO_REF_2');
      expect(secondPlace.address, '#150, 207 Queens Quay West, Toronto');
      expect(secondPlace.types, contains('store'));
    });

    /// Test case to verify exception is thrown when the HTTP response code is not 200
    test('should throw Exception when HTTP status code is not 200', () async {
      // Simulate failed HTTP response with status 500
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      // Expect an exception to be thrown due to non-200 status
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

    /// Test case to verify exception is thrown when Google Places API returns a non-OK status
    test('should throw Exception when Google Places API status is not OK',
        () async {
      // Simulate valid HTTP response with Google API error
      final mockErrorResponse = {
        "status": "REQUEST_DENIED",
        "error_message": "Invalid API key"
      };

      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockErrorResponse), 200),
      );

      // Expect an exception with the correct API error status
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

    /// Test case to verify exception is thrown on network failure
    test('should throw Exception on network failure', () async {
      // Simulate network failure (e.g., no internet, server unreachable)
      when(mockHttpClient.get(any)).thenThrow(Exception('Network Error'));

      // Expect a generic exception related to fetching data
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

    /// Test case to verify exception is thrown when the response contains invalid JSON
    test('should throw Exception on invalid JSON response', () async {
      // Simulate HTTP response with invalid JSON content
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('INVALID_JSON', 200),
      );

      // Expect an exception due to JSON parsing failure
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
