/// A utility class for mapping Google Places API JSON responses into
/// a simplified, application-specific format.
///
/// This class is used to extract and transform selected fields from
/// the full Google Places Details API response into a more convenient
/// `Map<String, dynamic>` structure for display or storage.
///
/// Example usage:
/// ```dart
/// final mapped = PlaceDetailsMapper.fromGoogleDetailsJson(
///   detailsJson,
///   "Hall Building",
///   dotenv.env['GOOGLE_MAPS_API_KEY']!,
/// );
/// print(mapped["phone"]);
/// ```
class PlaceDetailsMapper {
  /// Parses a Google Places API "place details" response and maps it into a simplified format.
  ///
  /// Parameters:
  /// - [json]: The full JSON response from the Places Details API.
  /// - [locationName]: A custom name to assign to the place (e.g. for internal labeling).
  /// - [apiKey]: The API key used to generate photo URLs (used in the `photo` field).
  ///
  /// Returns:
  /// - A `Map<String, dynamic>` containing selected fields:
  ///   - `"name"`: The provided [locationName]
  ///   - `"phone"`: Formatted phone number (if available)
  ///   - `"website"`: Website URL
  ///   - `"rating"`: Average user rating
  ///   - `"opening_hours"`: List of weekday hours (if available)
  ///   - `"types"`: List of place types (e.g., restaurant, university)
  ///   - `"photo"`: A generated URL to a photo if available, else `null`
  ///
  /// Notes:
  /// - If no photo is found, the `"photo"` field will be `null`.
  static Map<String, dynamic> fromGoogleDetailsJson(
      Map<String, dynamic> json, String locationName, String apiKey) {
    final result = json['result'] ?? {};

    String? photoUrl;
    if (result["photos"] != null && result["photos"].isNotEmpty) {
      final photoRef = result["photos"][0]["photo_reference"];
      photoUrl =
          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoRef&key=$apiKey";
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
}
