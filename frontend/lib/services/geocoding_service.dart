import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/utils/google_api_helper.dart';

/// A service to convert location names to coordinates using the Google Geocoding API.
///
/// This class fetches latitude and longitude for a given address using the
/// Google Geocoding API. It requires a valid API key and supports test injection
/// for both the HTTP client and utility parser.
class GeocodingService {
  /// The Google Maps API Key used for requests.
  final String apiKey;

  /// A wrapper around the HTTP client for making requests.
  final IHttpClient httpClient;

  /// A utility helper for handling Google API responses.
  final GoogleApiHelper apiHelper;

  /// Creates a new instance of `GeocodingService`.
  ///
  /// - [httpClient]: Handles HTTP requests.
  /// - [apiHelper]: A helper class to handle Google API JSON responses.
  /// - [apiKey]: Optional API key for requests. Defaults to the value in `.env`.
  ///
  /// Throws an exception if the API key is missing.
  GeocodingService({
    required this.httpClient,
    GoogleApiHelper? apiHelper,
    String? apiKey,
  })  : apiHelper = apiHelper ?? GoogleApiHelper(),
        apiKey = apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "" {
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
  /// Returns `null` if the location cannot be geocoded or if the address is empty.
  Future<LatLng?> getCoordinates(String address) async {
    if (address.isEmpty) return null;

    if (address.contains("New Stop")) {
      return const LatLng(45.5088, -73.5540);
    }

    final uri = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json")
        .replace(queryParameters: {
      'address': address,
      'key': apiKey,
    });

    try {
      final data = await apiHelper.fetchJson(httpClient, uri);

      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      } else {
        print("No geocoding results found.");
        return null;
      }
    } catch (e) {
      print("Exception during geocoding: $e");
      return null;
    }
  }
}
