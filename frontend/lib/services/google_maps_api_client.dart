/// This file contains the API class for fetching building information from Google Maps API.
/// The API key is stored in a ..env file and is accessed using the flutter_dotenv package.
/// The fetchBuildingInformation method takes in the latitude, longitude, and location name as parameters and returns a map of the location information.
///   - The latitude and longitude are used to fetch the place ID of the location.
///  - The place ID is then used to fetch the location details such as phone number, website, rating, opening hours, and types.
///  - The location information is stored in a map and returned.
///  - If the API key is not found, an exception is thrown.
/// - If no results are found for the given coordinates, an exception is thrown.
///   - The location information is printed to the console.
///  - The location information is returned as a map.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soen_390/services/interfaces/maps_api_client.dart';
import 'package:soen_390/utils/google_api_helper.dart';

class GoogleMapsApiClient implements MapsApiClient {
  final String apiKey;
  final http.Client client;
  final GoogleApiHelper apiHelper;

  GoogleMapsApiClient({
    required this.apiKey,
    required this.client,
    GoogleApiHelper? apiHelper,
  }) : apiHelper = apiHelper ?? GoogleApiHelper();

  @override
  Future<Map<String, dynamic>> fetchBuildingInformation(
      double latitude, double longitude, String locationName) async {
    const String placeSearchUrl =
        "https://maps.googleapis.com/maps/api/geocode/json";

    const String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json";

    const String placePhotoUrl =
        "https://maps.googleapis.com/maps/api/place/photo";

    final searchResponse = await client.get(
      Uri.parse("$placeSearchUrl?latlng=$latitude,$longitude&key=$apiKey"),
    );

    if (searchResponse.statusCode != 200) {
      throw Exception(
          'Failed to fetch location data: ${searchResponse.statusCode}');
    }

    final searchData = jsonDecode(searchResponse.body);

    if (searchData["results"] == null || searchData["results"].isEmpty) {
      throw Exception('No results found for the given coordinates.');
    }

    String placeId = searchData["results"][0]["place_id"];

    final detailsResponse = await client.get(
      Uri.parse(
          "$placeDetailsUrl?place_id=$placeId&key=$apiKey&fields=formatted_phone_number,website,rating,opening_hours,types,photos"),
    );

    if (detailsResponse.statusCode != 200) {
      throw Exception(
          'Failed to fetch details data: ${detailsResponse.statusCode}');
    }

    final detailsData = jsonDecode(detailsResponse.body);
    final result = detailsData["result"] ?? {};

    String? photoUrl;
    if (result["photos"] != null && result["photos"].isNotEmpty) {
      String photoReference = result["photos"][0]["photo_reference"];
      photoUrl =
          "$placePhotoUrl?maxwidth=400&photo_reference=$photoReference&key=$apiKey";
    }

    Map<String, dynamic> locationInfo = {
      "name": locationName,
      "phone": result["formatted_phone_number"],
      "website": result["website"],
      "rating": result["rating"],
      "opening_hours": result["opening_hours"]?["weekday_text"] ?? [],
      "types": result["types"] ?? [],
      "photo": photoUrl,
    };

    print("Location Info for $locationName ($latitude, $longitude):");
    print(locationInfo);

    return locationInfo;
  }

  /// Fetches detailed information about a place using its [placeId] from
  /// the Google Places API.
  ///
  /// This function constructs a request to the Google Places Details API
  /// using the provided [placeId] and retrieves specific fields of interest
  /// such as address, phone number, website, rating, opening hours, types,
  /// reviews, and more.
  ///
  /// The API response is parsed, and the result is returned as a
  /// `Map<String, dynamic>`, which includes the requested place details.
  ///
  /// Throws an [Exception] if the API request fails (non-200 HTTP status)
  /// or if the API returns an error status.
  ///
  /// Example usage:
  /// ```dart
  /// final placeDetails = await fetchPlaceDetailsById("ChIJN1t_tDeuEmsRUsoyG83frY4");
  /// print(placeDetails["name"]);
  /// ```
  ///
  /// Parameters:
  /// - [placeId]: A unique identifier for the place you want details about,
  ///   as provided by the Google Places API.
  ///
  /// Returns:
  /// - A `Future<Map<String, dynamic>>` containing the place details if
  ///   the request is successful.
  ///
  /// Exceptions:
  /// - Throws an [Exception] with an error message if the request fails or
  ///   the API status is not "OK".
  Future<Map<String, dynamic>> fetchPlaceDetailsById(String placeId) async {
    const String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json";

    // Fields you want from the API
    const fields = [
      "formatted_address",
      "formatted_phone_number",
      "website",
      "rating",
      "opening_hours",
      "types",
      "reviews",
      "editorial_summary",
      "price_level",
      "name",
      'geometry',
    ];

    final uri = Uri.parse(
      "$placeDetailsUrl?place_id=$placeId&fields=${fields.join(',')}&key=$apiKey",
    );

    print("Fetching place details for placeId: $placeId");
    print("Request URL: $uri");

    final response = await client.get(uri);

    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch place details: ${response.statusCode}');
    }

    final detailsData = jsonDecode(response.body);

    if (detailsData["status"] != "OK") {
      throw Exception('API Error: ${detailsData["status"]}');
    }

    print("Fetched place details successfully");

    return detailsData["result"] ?? {};
  }
}
