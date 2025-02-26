/// This file contains the API class for fetching building information from Google Maps API.
/// The API key is stored in a .env file and is accessed using the flutter_dotenv package.
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

abstract class MapsApiClient {
  Future<Map<String, dynamic>> fetchBuildingInformation(
      double latitude, double longitude, String locationName);
}

class GoogleMapsApiClient implements MapsApiClient {
  final String apiKey;
  final http.Client client; // Inject the http client

  GoogleMapsApiClient({required this.apiKey, required this.client});

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
}

class BuildingPopUps {
  final MapsApiClient mapsApiClient;

  BuildingPopUps({required this.mapsApiClient});

  Future<Map<String, dynamic>> getBuildingInfo(
      double latitude, double longitude, String locationName) {
    return mapsApiClient.fetchBuildingInformation(
        latitude, longitude, locationName);
  }
}