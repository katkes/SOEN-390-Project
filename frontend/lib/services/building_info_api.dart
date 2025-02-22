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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BuildingPopUps {
  final String apiKey = dotenv.env['API_KEY'] ?? 'API_KEY_NOT_FOUND';
  
  Future<Map<String, dynamic>> getLocationInfo(double latitude, double longitude, String locationName) async {
    if (apiKey == 'API_KEY_NOT_FOUND') {
      throw Exception('API key not found');
    }
    const String placeSearchUrl = "https://maps.googleapis.com/maps/api/geocode/json";

    const String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json";

    const String placePhotoUrl = "https://maps.googleapis.com/maps/api/place/photo";

    final searchResponse = await http.get(
      Uri.parse("$placeSearchUrl?latlng=$latitude,$longitude&key=$apiKey"),);
    
    final searchData = jsonDecode(searchResponse.body);

    if(searchData["results"]==null || searchData["results"].isEmpty){
      throw Exception('No results found for the given coordinates.');
    }

    String placeId = searchData["results"][0]["place_id"];

    final detailsResponse = await http.get(
     Uri.parse("$placeDetailsUrl?place_id=$placeId&key=$apiKey&fields=formatted_phone_number,website,rating,opening_hours,types,photos"),
    );

    final detailsData = jsonDecode(detailsResponse.body);
    final result = detailsData["result"] ?? {};

    String? photoUrl;
    if (result["photos"] != null && result["photos"].isNotEmpty) {
      String photoReference = result["photos"][0]["photo_reference"];
      photoUrl = "$placePhotoUrl?maxwidth=400&photo_reference=$photoReference&key=$apiKey";
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