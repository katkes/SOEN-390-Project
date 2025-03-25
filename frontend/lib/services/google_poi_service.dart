import 'package:soen_390/services/interfaces/base_google_service.dart';
import '../models/places.dart';

/// A service that fetches nearby points of interest (POIs) using the Google Places API.
///
/// This service uses the `nearbysearch` endpoint from the Google Places API
/// to search for nearby locations (e.g., restaurants, ATMs, libraries, etc.)
/// based on coordinates, type, and search radius.
///
/// It extends [BaseGoogleService], inheriting the API key, HTTP client,
/// and API helper for making and validating Google API requests.
///
/// Example usage:
/// ```dart
/// final poiService = GooglePOIService(httpClient: HttpService());
/// final results = await poiService.getNearbyPlaces(
///   latitude: 45.5017,
///   longitude: -73.5673,
///   type: 'restaurant',
///   radius: 1000,
/// );
/// results.forEach((place) => print(place.name));
/// ```
class GooglePOIService extends BaseGoogleService {
  /// Base URL for the Google Places Nearby Search API.
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  /// Constructs a [GooglePOIService] instance.
  ///
  /// Requires a [httpClient] for performing network requests.
  ///
  /// Optionally accepts:
  /// - [apiHelper] to override the default [GoogleApiHelper] instance
  /// - [apiKey] to override the key loaded from `.env`
  ///
  /// Throws:
  /// - [Exception] if the API key is missing or empty (handled in [BaseGoogleService]).
  GooglePOIService({
    required super.httpClient,
    super.apiHelper,
    super.apiKey,
  });

  /// Fetches a list of nearby places of a given [type] around a specific location.
  ///
  /// The request is made to the Google Places API `nearbysearch` endpoint.
  ///
  /// Parameters:
  /// - [latitude]: Latitude of the center point.
  /// - [longitude]: Longitude of the center point.
  /// - [type]: Type of place to search for (e.g., 'restaurant', 'atm', 'library').
  /// - [radius]: Radius (in meters) around the location to search within.
  ///
  /// Returns:
  /// - A `Future<List<Place>>` containing nearby places mapped from the JSON response.
  ///
  /// Throws:
  /// - [Exception] if the API request fails or returns an error.
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
    required int radius,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'location': '$latitude,$longitude',
      'radius': radius.toString(),
      'type': type,
      'key': apiKey, //  inherited from BaseGoogleService
    });

    try {
      final data = await apiHelper.fetchJson(
          httpClient, uri); //  use inherited properties
      final results = data['results'] as List<dynamic>;
      return results.map((place) => Place.fromJson(place)).toList();
    } catch (e) {
      throw Exception('Error fetching nearby places: $e');
    }
  }
}
