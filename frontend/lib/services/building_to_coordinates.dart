import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import '../services/http_service.dart';

/// A service to convert location names to coordinates using the Google Geocoding API.
class GeocodingService {
  /// The Google Maps API Key used for requests.
  final String apiKey;

  /// A wrapper around the HTTP client for making requests.
  final HttpService httpService;

  /// Creates a new instance of `GeocodingService`.
  ///
  /// - [httpService]: Handles HTTP requests.
  /// - [apiKey]: Optional API key for requests. Defaults to the value in `.env`.
  ///
  /// Throws an exception if the API key is missing.
  GeocodingService({
    required this.httpService,
    String? apiKey, // Allow passing an API key for testing
  }) : apiKey = apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "" {
    if (this.apiKey.isEmpty) {
      throw Exception(
          "ERROR: Missing Google Maps API Key! Provide one or check your .env file.");
    }
  }

  /// Converts a location name to coordinates using the Google Geocoding API.
  ///
  /// - [address]: The location name or address to geocode.
  ///
  /// Returns a `LatLng` containing the coordinates for the location.
  /// Returns `null` if the location cannot be geocoded.
  Future<LatLng?> getCoordinates(String address) async {
    if (address.isEmpty) {
      return null;
    }

    if (address.contains("New Stop")) {
      return const LatLng(45.5088, -73.5540);
    }

    String url = "https://maps.googleapis.com/maps/api/geocode/json?"
        "address=${Uri.encodeComponent(address)}"
        "&key=$apiKey";

    try {
      final response = await httpService.client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        } else {
          print("Geocoding API Error: ${data['status']}");
          return null;
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception during geocoding: $e");
      return null;
    }
  }
}
