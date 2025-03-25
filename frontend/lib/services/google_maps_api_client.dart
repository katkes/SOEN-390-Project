import 'package:soen_390/services/interfaces/maps_api_client.dart';
import 'package:soen_390/services/interfaces/base_google_service.dart';

/// A client for interacting with the Google Maps and Places APIs.
///
/// This class extends [BaseGoogleService] and implements the [MapsApiClient] interface,
/// enabling functionality to:
/// - Fetch a place's details using its geographic coordinates (latitude/longitude)
/// - Fetch rich information about a place using its unique Google Places `placeId`
///
/// This client uses Google’s Geocoding and Places APIs, including the `nearbysearch`,
/// `details`, and `photo` endpoints.
///
/// Example usage:
/// ```dart
/// final mapsClient = GoogleMapsApiClient(
///   apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
///   httpClient: HttpService(),
/// );
///
/// final info = await mapsClient.fetchBuildingInformation(
///   45.5017, -73.5673, "Hall Building",
/// );
///
/// final placeDetails = await mapsClient.fetchPlaceDetailsById("ChIJN1t_tDeuEmsRUsoyG83frY4");
/// ```
class GoogleMapsApiClient extends BaseGoogleService implements MapsApiClient {
  /// Creates an instance of [GoogleMapsApiClient].
  ///
  /// Requires:
  /// - [apiKey]: A valid Google Maps API key.
  /// - [httpClient]: A custom HTTP client implementing [IHttpClient].
  ///
  /// Optionally:
  /// - [apiHelper]: A custom instance of [GoogleApiHelper] for API response handling.
  ///
  /// Throws:
  /// - [Exception] if [apiKey] is not provided or is empty (handled in [BaseGoogleService]).
  GoogleMapsApiClient({
    required super.apiKey,
    required super.httpClient,
    super.apiHelper,
  });

  /// Fetches building/place information using geographic coordinates.
  ///
  /// First, it calls the Google Geocoding API to resolve a `place_id` using the
  /// provided [latitude] and [longitude]. Then it queries the Places Details API
  /// to retrieve details like:
  /// - Formatted phone number
  /// - Website URL
  /// - User rating
  /// - Opening hours
  /// - Place types
  /// - Photo reference
  ///
  /// Returns:
  /// - A `Map<String, dynamic>` containing the location details, including:
  ///   - `"name"`: The provided [locationName]
  ///   - `"phone"`, `"website"`, `"rating"`, `"opening_hours"`, `"types"`, `"photo"`
  ///
  /// Throws:
  /// - [Exception] if no results are found or if any of the API calls fail.
  ///
  /// Parameters:
  /// - [latitude]: Latitude of the location.
  /// - [longitude]: Longitude of the location.
  /// - [locationName]: The custom display name to assign in the returned map.
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

  /// Fetches detailed information about a place using its [placeId].
  ///
  /// Uses the Google Places Details API to retrieve extended place information,
  /// including:
  /// - Address, phone number, website
  /// - Opening hours, types, name
  /// - User rating, reviews, summary, price level
  /// - Geometry (location + viewport)
  ///
  /// Returns:
  /// - A `Map<String, dynamic>` representing the `"result"` field from the API response.
  ///
  /// Throws:
  /// - [Exception] if the API request fails or the API returns a non-OK status.
  ///
  /// Parameters:
  /// - [placeId]: A unique identifier for a place from Google Places API.
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
