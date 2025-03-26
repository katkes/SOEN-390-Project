import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:soen_390/services/google_maps_api_client.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/widgets/building_popup.dart';

@GenerateMocks([IHttpClient])
import 'google_maps_api_client_test.mocks.dart';

/// **Unit tests for `GoogleMapsApiClient`**
///
/// These tests verify the correctness of the `fetchBuildingInformation`
/// method by simulating API responses using a mocked HTTP mockHttpClient.
///
/// ## **Why These Tests Exist**
/// - The `GoogleMapsApiClient` interacts with **Google Maps API** to fetch **building information**.
/// - To **avoid real API calls**, we use `MockClient` to simulate expected API responses.
/// - The tests ensure that **various scenarios** are handled correctly, including:
///   -  **Successful data retrieval**
///   -  **Invalid API key**
///   -  **No search results**
///   -  **Server failures**
///   -  **Missing API key**
///
/// ## **Mocking API Calls**
/// - **Mockito** is used to stub `http.Client.get()` responses.
/// - Instead of calling Google Maps API, we provide **predefined JSON responses**.
/// - This allows us to test the logic **without network dependency**.
void main() {
  group('GoogleMapsApiClient Tests', () {
    late MockIHttpClient mockHttpClient;
    late GoogleMapsApiClient mapsApiClient;
    const String apiKey = 'FAKE_API_KEY'; // Mocked API key
    late BuildingPopUps retriever;

    setUp(() {
      mockHttpClient = MockIHttpClient();
      mapsApiClient =
          GoogleMapsApiClient(apiKey: apiKey, httpClient: mockHttpClient);

      retriever = BuildingPopUps(mapsApiClient: mapsApiClient);

      /// **Prevents unmocked API calls from causing test failures.**
      when(mockHttpClient.get(any)).thenThrow(
          Exception("Unexpected API call. Ensure all requests are stubbed."));
    });

    /// **Test: Successful retrieval of building information**
    ///
    /// **Scenario:**
    /// - The API returns **valid geocode and place details data**.
    /// - The function correctly **extracts and returns** building information.
    ///
    /// **Expected Outcome:**
    /// - The response contains the expected `name`, `phone`, `website`, `rating`, `opening_hours`, `types`, and `photo`.
    test('fetchBuildingInformation should return valid location data',
        () async {
      when(mockHttpClient.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/geocode/json?latlng=37.7749,-122.4194&key=$apiKey")))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                "results": [
                  {"place_id": "test_place_id"}
                ],
                "status": "OK"
              }),
              200));

      when(mockHttpClient.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/place/details/json?place_id=test_place_id&key=$apiKey&fields=formatted_phone_number,website,rating,opening_hours,types,photos")))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  "status": "OK",
                  "result": {
                    "formatted_phone_number": "123-456-7890",
                    "website": "https://example.com",
                    "rating": 4.7,
                    "opening_hours": {
                      "weekday_text": ["Monday: 9:00 AM - 5:00 PM"]
                    },
                    "types": ["restaurant"],
                    "photos": [
                      {"photo_reference": "test_photo_ref"}
                    ]
                  }
                }),
                200,
              ));

      final result = await retriever.fetchBuildingInformation(
          37.7749, -122.4194, "Test Location");

      expect(result, isA<Map<String, dynamic>>());
      expect(result["name"], "Test Location");
      expect(result["phone"], "123-456-7890");
      expect(result["website"], "https://example.com");
      expect(result["rating"], 4.7);
      expect(result["opening_hours"], contains("Monday: 9:00 AM - 5:00 PM"));
      expect(result["types"], contains("restaurant"));
      expect(result["photo"], contains("test_photo_ref"));
    });

    /// **Test: API key is invalid**
    ///
    /// **Scenario:**
    /// - The API returns a **403 Forbidden** error due to an invalid API key.
    ///
    /// **Expected Outcome:**
    /// - The function should throw an `Exception`.
    test('fetchBuildingInformation should throw an error for invalid API key',
        () async {
      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response('Invalid API key', 403));

      expect(
          () async => await retriever.fetchBuildingInformation(
              37.7749, -122.4194, "Test Location"),
          throwsA(isA<Exception>()));
    });

    /// **Test: No results found for the given coordinates**
    ///
    /// **Scenario:**
    /// - The geocode API returns `"ZERO_RESULTS"`, meaning no places match the query.
    ///
    /// **Expected Outcome:**
    /// - The function should throw an `Exception`.
    test(
        'fetchBuildingInformation should throw an error if no results are found',
        () async {
      when(mockHttpClient.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/geocode/json?latlng=37.7749,-122.4194&key=$apiKey")))
          .thenAnswer((_) async => http.Response(
              jsonEncode({"results": [], "status": "ZERO_RESULTS"}), 200));

      expect(
          () async => await retriever.fetchBuildingInformation(
              37.7749, -122.4194, "Test Location"),
          throwsA(isA<Exception>()));
    });

    /// **Test: API request fails due to a server error**
    ///
    /// **Scenario:**
    /// - The API returns a `500 Internal Server Error`.
    ///
    /// **Expected Outcome:**
    /// - The function should throw an `Exception`.
    test('fetchBuildingInformation should throw an error if API request fails',
        () async {
      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response('Server error', 500));

      expect(
          () async => await retriever.fetchBuildingInformation(
              37.7749, -122.4194, "Test Location"),
          throwsA(isA<Exception>()));
    });

    /// **Test: API key is missing**
    ///
    /// **Scenario:**
    /// - The API key is empty (`""`), making the API request invalid.
    /// - The API should return a `403 Forbidden` error.
    ///
    /// **Expected Outcome:**
    /// - The function should throw an `Exception`.
    test('should throw if API key is missing during construction', () {
      expect(
        () => GoogleMapsApiClient(apiKey: '', httpClient: mockHttpClient),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Missing Google Maps API Key'),
        )),
      );
    });
  });

  /// **Tests for fetchPlaceDetailsById**
  group('fetchPlaceDetailsById Tests', () {
    late MockIHttpClient mockHttpClient;
    late GoogleMapsApiClient mapsApiClient;
    const String apiKey = 'FAKE_API_KEY';

    setUp(() {
      mockHttpClient = MockIHttpClient();
      mapsApiClient =
          GoogleMapsApiClient(apiKey: apiKey, httpClient: mockHttpClient);
    });

    test('fetchPlaceDetailsById should return valid place details', () async {
      const placeId = 'test_place_id';
      final testResponse = {
        "status": "OK",
        "result": {
          "formatted_address": "123 Test St",
          "formatted_phone_number": "123-456-7890",
          "website": "https://example.com",
          "rating": 4.5,
          "opening_hours": {
            "weekday_text": ["Monday: 9:00 AM - 5:00 PM"]
          },
          "types": ["cafe"],
          "reviews": [],
          "editorial_summary": {"overview": "Great place"},
          "price_level": 2,
          "name": "Test Cafe",
          "geometry": {
            "location": {"lat": 40.7128, "lng": -74.0060}
          }
        }
      };

      final uri = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,formatted_phone_number,website,rating,opening_hours,types,reviews,editorial_summary,price_level,name,geometry&key=$apiKey");

      when(mockHttpClient.get(uri)).thenAnswer(
          (_) async => http.Response(jsonEncode(testResponse), 200));

      final result = await mapsApiClient.fetchPlaceDetailsById(placeId);

      expect(result, isA<Map<String, dynamic>>());
      expect(result["name"], "Test Cafe");
      expect(result["rating"], 4.5);
      expect(result["formatted_address"], "123 Test St");
      expect(result["geometry"], isNotNull);
      expect(result["geometry"]["location"]["lat"], 40.7128);
    });

    test(
        'fetchPlaceDetailsById should throw exception when response status code is not 200',
        () async {
      const placeId = 'test_place_id';
      final uri = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,formatted_phone_number,website,rating,opening_hours,types,reviews,editorial_summary,price_level,name,geometry&key=$apiKey");

      when(mockHttpClient.get(uri))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      expect(() async => await mapsApiClient.fetchPlaceDetailsById(placeId),
          throwsA(isA<Exception>()));
    });

    test(
        'fetchPlaceDetailsById should throw exception when API status is not OK',
        () async {
      const placeId = 'test_place_id';
      final errorResponse = {
        "status": "REQUEST_DENIED",
        "error_message": "Invalid API key."
      };

      final uri = Uri.parse(
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,formatted_phone_number,website,rating,opening_hours,types,reviews,editorial_summary,price_level,name,geometry&key=$apiKey");

      when(mockHttpClient.get(uri)).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 200));

      expect(() async => await mapsApiClient.fetchPlaceDetailsById(placeId),
          throwsA(isA<Exception>()));
    });
  });
}
