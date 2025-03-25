import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/utils/google_api_helper.dart';
import '../models/places.dart';
import 'http_service.dart';

/// A service that fetches nearby places of interest (POIs) using the
/// Google Places API.
///
/// This class leverages an [HttpService] to make HTTP requests and requires
/// a valid Google Places API key to function.
class GooglePOIService {
  final IHttpClient _httpClient;
  final String _apiKey;
  final GoogleApiHelper _apiHelper;

  /// Base URL for Google Places Nearby Search API.
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  /// Creates a [GooglePOIService] instance.
  ///
  /// - [apiKey]: A valid Google Places API key.
  /// - [httpClient]: Optional injected HTTP client.
  /// - [apiHelper]: Optional injected utility for parsing responses.
  ///
  /// Throws if [apiKey] is missing or empty.
  GooglePOIService({
    required String apiKey,
    IHttpClient? httpClient,
    GoogleApiHelper? apiHelper,
  })  : _apiKey = apiKey,
        _httpClient = httpClient ?? HttpService(),
        _apiHelper = apiHelper ?? GoogleApiHelper();

  /// Fetches a list of nearby places of a specified [type] within a given
  /// [radius] around the provided [latitude] and [longitude].
  ///
  /// - [latitude]: The latitude coordinate of the search center.
  /// - [longitude]: The longitude coordinate of the search center.
  /// - [type]: The type of place to search for (e.g., `restaurant`, `park`).
  /// - [radius]: The search radius in meters.
  ///
  /// Returns a [Future] that completes with a list of [Place] objects if
  /// successful.
  ///
  /// Throws an [Exception] if the request fails or the Google Places API
  /// returns an error.
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
      'key': _apiKey,
    });

    try {
      final data = await _apiHelper.fetchJson(_httpClient, uri);
      final results = data['results'] as List<dynamic>;
      return results.map((place) => Place.fromJson(place)).toList();
    } catch (e) {
      throw Exception('Error fetching nearby places: $e');
    }
  }
}
