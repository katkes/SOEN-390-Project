import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:soen_390/services/building_info_api.dart';

@GenerateMocks([http.Client])
import 'building_info_retrieval_test.mocks.dart';

/// **Unit tests for `GoogleMapsApiClient`**
///
/// These tests verify the correctness of the `fetchBuildingInformation`
/// method by simulating API responses using a mocked HTTP client.
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
    late MockClient client;
    late GoogleMapsApiClient mapsApiClient;
    const String apiKey = 'FAKE_API_KEY'; // Mocked API key
    late BuildingPopUps retriever;

    setUp(() {
      client = MockClient();
      mapsApiClient = GoogleMapsApiClient(apiKey: apiKey, client: client);
      retriever = BuildingPopUps(mapsApiClient: mapsApiClient);

      /// **Prevents unmocked API calls from causing test failures.**
      when(client.get(any)).thenThrow(
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
      when(client.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/geocode/json?latlng=37.7749,-122.4194&key=$apiKey")))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                "results": [
                  {"place_id": "test_place_id"}
                ],
                "status": "OK"
              }),
              200));

      when(client.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/place/details/json?place_id=test_place_id&key=$apiKey&fields=formatted_phone_number,website,rating,opening_hours,types,photos")))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
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
              200));

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
      when(client.get(any))
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
      when(client.get(Uri.parse(
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
      when(client.get(any))
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
    test('fetchBuildingInformation should throw an error if API key is missing',
        () async {
      final mapsApiClientNoKey =
          GoogleMapsApiClient(apiKey: '', client: client);

      when(client.get(Uri.parse(
              "https://maps.googleapis.com/maps/api/geocode/json?latlng=37.7749,-122.4194&key=")))
          .thenAnswer((_) async => http.Response('Invalid API key', 403));

      expect(
          () async => await mapsApiClientNoKey.fetchBuildingInformation(
              37.7749, -122.4194, "Test Location"),
          throwsA(isA<Exception>()));
    });
  });
}
