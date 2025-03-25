/// This library defines a client for interacting with the Google Maps and Places APIs.
///
/// It provides methods to fetch building/location details such as phone number,
/// website, rating, opening hours, types, and photo using coordinates or a place ID.
///
/// The API key used for requests is expected to be stored in a `.env` file and
/// accessed using the `flutter_dotenv` package.
///
/// The class supports:
/// - Fetching place ID based on latitude and longitude.
/// - Retrieving detailed place information using the place ID.
/// - Graceful error handling for missing API key or failed requests.
///
/// Example usage:
/// ```dart
/// final client = GoogleMapsApiClient(
///   apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
///   httpClient: HttpService(),
/// );
/// final info = await client.fetchBuildingInformation(45.5, -73.6, "My Building");
/// print(info['phone']);
/// ```
library;

import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/services/interfaces/maps_api_client.dart';
import 'package:soen_390/utils/google_api_helper.dart';

/// A client for interacting with Google Maps and Places APIs.
class GoogleMapsApiClient implements MapsApiClient {
  /// The API key used to authenticate with the Google Maps API.
  final String apiKey;

  /// The HTTP client used for sending requests.
  final IHttpClient httpClient;

  /// Helper used to fetch and validate API responses.
  final GoogleApiHelper apiHelper;

  /// Creates a [GoogleMapsApiClient] with the provided [apiKey], [httpClient],
  /// and an optional [apiHelper]. If [apiHelper] is not provided, a default
  /// instance is used.
  GoogleMapsApiClient({
    required this.apiKey,
    required this.httpClient,
    GoogleApiHelper? apiHelper,
  }) : apiHelper = apiHelper ?? GoogleApiHelper();

  /// Fetches detailed building/location information based on latitude and longitude.
  ///
  /// This method first queries the Google Geocoding API to retrieve the `place_id`
  /// for the provided [latitude] and [longitude]. Then it uses that `place_id` to
  /// request detailed information from the Places Details API.
  ///
  /// The returned map includes:
  /// - `name`: The custom name provided.
  /// - `phone`: Formatted phone number (if available).
  /// - `website`: Website URL.
  /// - `rating`: Average user rating.
  /// - `opening_hours`: A list of weekday opening hours.
  /// - `types`: List of place types (e.g., university, building).
  /// - `photo`: A Google Maps photo URL, if available.
  ///
  /// Throws:
  /// - [Exception] if the API key is invalid or missing.
  /// - [Exception] if no results are found for the given coordinates.
  ///
  /// Example:
  /// ```dart
  /// final info = await client.fetchBuildingInformation(45.5017, -73.5673, "Hall Building");
  /// print(info["rating"]);
  /// ```
  @override
  Future<Map<String, dynamic>> fetchBuildingInformation(
    double latitude,
    double longitude,
    String locationName,
  ) async {
    const placeSearchUrl = "https://maps.googleapis.com/maps/api/geocode/json";
    const placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json";
    const placePhotoUrl = "https://maps.googleapis.com/maps/api/place/photo";

    final searchUri =
        Uri.parse("$placeSearchUrl?latlng=$latitude,$longitude&key=$apiKey");

    final searchData = await apiHelper.fetchJson(httpClient, searchUri);

    if (searchData["results"] == null || searchData["results"].isEmpty) {
      throw Exception('No results found for the given coordinates.');
    }

    final placeId = searchData["results"][0]["place_id"];

    final detailsUri = Uri.parse(
      "$placeDetailsUrl?place_id=$placeId&key=$apiKey"
      "&fields=formatted_phone_number,website,rating,opening_hours,types,photos",
    );

    final detailsData = await apiHelper.fetchJson(httpClient, detailsUri);
    final result = detailsData["result"] ?? {};

    String? photoUrl;
    if (result["photos"] != null && result["photos"].isNotEmpty) {
      final photoReference = result["photos"][0]["photo_reference"];
      photoUrl =
          "$placePhotoUrl?maxwidth=400&photo_reference=$photoReference&key=$apiKey";
    }

    return {
      "name": locationName,
      "phone": result["formatted_phone_number"],
      "website": result["website"],
      "rating": result["rating"],
      "opening_hours": result["opening_hours"]?["weekday_text"] ?? [],
      "types": result["types"] ?? [],
      "photo": photoUrl,
    };
  }

  /// Fetches detailed information about a place using its [placeId] from
  /// the Google Places Details API.
  ///
  /// This method retrieves rich details about a place, including:
  /// - `name`
  /// - `address`
  /// - `phone`
  /// - `website`
  /// - `rating`
  /// - `types`
  /// - `opening_hours`
  /// - `geometry`
  /// - `reviews`, etc.
  ///
  /// Throws:
  /// - [Exception] if the HTTP request fails or the response status is not "OK".
  ///
  /// Returns:
  /// - A `Map<String, dynamic>` containing the place details.
  ///
  /// Example:
  /// ```dart
  /// final details = await client.fetchPlaceDetailsById("ChIJN1t_tDeuEmsRUsoyG83frY4");
  /// print(details["name"]);
  /// ```
  @override
  Future<Map<String, dynamic>> fetchPlaceDetailsById(String placeId) async {
    const placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json";

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
      "geometry",
    ];

    final uri = Uri.parse(
      "$placeDetailsUrl?place_id=$placeId&fields=${fields.join(',')}&key=$apiKey",
    );

    final detailsData = await apiHelper.fetchJson(httpClient, uri);
    return detailsData["result"] ?? {};
  }
}
