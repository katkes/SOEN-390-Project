import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/utils/google_api_helper.dart';

import 'google_poi_service_test.mocks.dart';

/// Generate mock classes
@GenerateNiceMocks([
  MockSpec<IHttpClient>(),
  MockSpec<GoogleApiHelper>(),
])
void main() {
  late MockIHttpClient mockHttpClient;
  late MockGoogleApiHelper mockApiHelper;
  late GooglePOIService poiService;

  const mockApiKey = 'test-api-key';

  setUp(() {
    mockHttpClient = MockIHttpClient();
    mockApiHelper = MockGoogleApiHelper();
    poiService = GooglePOIService(
      apiKey: mockApiKey,
      httpClient: mockHttpClient,
      apiHelper: mockApiHelper,
    );
  });

  group('GooglePOIService Tests', () {
    test('should parse all fields from full API response accurately', () async {
      final mockJsonResponse = {
        "results": [
          {
            "name": "The Goodman Pub and Kitchen",
            "place_id": "PLACE_ID_1",
            "business_status": "OPERATIONAL",
            "geometry": {
              "location": {"lat": 43.6383548, "lng": -79.3801917},
            },
            "vicinity": "207 Queens Quay West, Toronto",
            "types": ["bar", "restaurant", "food"],
            "rating": 4.1,
            "user_ratings_total": 3050,
            "price_level": 2,
            "opening_hours": {"open_now": false},
            "photos": [
              {"photo_reference": "PHOTO_REF_1"}
            ],
            "icon":
                "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/bar-71.png",
            "plus_code": {"compound_code": "JJQ9+8W Toronto, ON, Canada"}
          }
        ]
      };

      when(mockApiHelper.fetchJson(any, any)).thenAnswer(
        (_) async => mockJsonResponse,
      );

      final places = await poiService.getNearbyPlaces(
        latitude: 43.6383,
        longitude: -79.3801,
        type: 'restaurant',
        radius: 500,
      );

      expect(places.length, 1);
      expect(places[0].name, 'The Goodman Pub and Kitchen');
      expect(places[0].placeId, 'PLACE_ID_1'); // ✅ Fix here
    });

    test('should throw Exception when fetchJson throws HTTP error', () async {
      when(mockApiHelper.fetchJson(any, any))
          .thenThrow(Exception('HTTP Error: 500'));

      expect(
        () => poiService.getNearbyPlaces(
          latitude: 43.6383,
          longitude: -79.3801,
          type: 'restaurant',
          radius: 500,
        ),
        throwsA(predicate(
            (e) => e is Exception && e.toString().contains('HTTP Error'))),
      );
    });

    test('should throw Exception when fetchJson throws API error', () async {
      when(mockApiHelper.fetchJson(any, any))
          .thenThrow(Exception('API Error: REQUEST_DENIED'));

      expect(
        () => poiService.getNearbyPlaces(
          latitude: 43.6383,
          longitude: -79.3801,
          type: 'restaurant',
          radius: 500,
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('API Error: REQUEST_DENIED'))),
      );
    });

    test('should throw Exception on generic failure', () async {
      when(mockApiHelper.fetchJson(any, any))
          .thenThrow(Exception('Some generic error'));

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
