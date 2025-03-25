import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/base_google_service.dart';

/// A service for converting human-readable location names (addresses)
/// into geographic coordinates (latitude and longitude) using the
/// Google Geocoding API.
///
/// This service extends [BaseGoogleService], inheriting shared functionality
/// such as API key management, HTTP client usage, and API response validation.
///
/// Example usage:
/// ```dart
/// final service = GeocodingService(httpClient: HttpService());
/// final coords = await service.getCoordinates("Concordia University");
/// print(coords); // LatLng(45.4972, -73.5790)
/// ```
class GeocodingService extends BaseGoogleService {
  /// Creates a new instance of [GeocodingService].
  ///
  /// Requires a [httpClient] for making HTTP requests.
  ///
  /// Optionally accepts:
  /// - [apiHelper] to provide a custom instance of [GoogleApiHelper]
  /// - [apiKey] to override the default API key loaded from `.env`
  ///
  /// Throws:
  /// - [Exception] if the API key is not found or empty.
  GeocodingService({
    required super.httpClient,
    super.apiHelper,
    super.apiKey,
  });

  /// Converts a given address or location name into geographical coordinates
  /// using the Google Geocoding API.
  ///
  /// Parameters:
  /// - [address]: A human-readable address or place name to convert into coordinates.
  ///
  /// Returns:
  /// - A [LatLng] object representing the latitude and longitude of the given address.
  /// - Returns `null` if the address is empty or if no results are found.
  ///
  /// Notes:
  /// - If the address contains the placeholder "New Stop", a fixed coordinate
  ///   for downtown Montreal is returned (used for mock/test purposes).
  ///
  /// Throws:
  /// - Catches exceptions during the HTTP or decoding process and logs them to console.
  Future<LatLng?> getCoordinates(String address) async {
    if (address.isEmpty) return null;

    // Fallback for mock addresses
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
