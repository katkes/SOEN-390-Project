/// A data model representing a place of interest retrieved from the
/// Google Places API.
///
/// This class provides essential details such as the place's name, location,
/// business status, ratings, price level, and metadata like photos and place types.
/// It also includes helper methods to simplify UI rendering of these details.
class Place {
  /// The name of the place (e.g., "Central Park").
  final String name;

  /// The unique identifier for the place, provided by the Google Places API.
  final String placeId;

  /// The current operational status of the place (e.g., "OPERATIONAL").
  final String businessStatus;

  /// The latitude coordinate of the place's location.
  final double latitude;

  /// The longitude coordinate of the place's location.
  final double longitude;

  /// A textual address or vicinity of the place (e.g., "New York, NY").
  final String address;

  /// A list of types/categories that describe the place
  /// (e.g., ["restaurant", "park", "museum"]).
  final List<String> types;

  /// The average user rating for the place on a scale from 0.0 to 5.0.
  final double rating;

  /// The total number of user-submitted ratings for the place.
  final int userRatingsTotal;

  /// Indicates how expensive the place is, on a scale from 0 (free) to 4 (very expensive).
  /// Null if this information is not available.
  final int? priceLevel;

  /// Indicates whether the place is currently open to the public, if available.
  /// Null if opening hours data is not provided.
  final bool? openNow;

  /// A token used to retrieve a photo of the place via the Google Places Photos API.
  /// Null if no photo is available.
  final String? photoReference;

  /// URL of the icon representing the place type (e.g., restaurant icon).
  final String iconUrl;

  /// A short, shareable code representing the location (e.g., "87G8+XF New York").
  /// Null if not provided.
  final String? plusCode;

  /// Constructs a [Place] object with the specified details.
  ///
  /// Required fields include [name], [placeId], [businessStatus], [latitude],
  /// [longitude], [address], [types], [rating], [userRatingsTotal], and [iconUrl].
  /// Optional fields are [priceLevel], [openNow], [photoReference], and [plusCode].
  Place({
    required this.name,
    required this.placeId,
    required this.businessStatus,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.types,
    required this.rating,
    required this.userRatingsTotal,
    this.priceLevel,
    this.openNow,
    this.photoReference,
    required this.iconUrl,
    this.plusCode,
  });

  /// Factory constructor that creates a [Place] instance from a JSON map
  /// returned by the Google Places API.
  ///
  /// This parses nested fields such as `geometry`, `opening_hours`, `photos`,
  /// and `plus_code`.
  ///
  /// Throws a [FormatException] if required fields are missing or improperly formatted.
  factory Place.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry['location'];

    return Place(
      name: json['name'],
      placeId: json['place_id'],
      businessStatus: json['business_status'],
      latitude: location['lat'],
      longitude: location['lng'],
      address: json['vicinity'],
      types: List<String>.from(json['types']),
      rating: (json['rating'] as num).toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      priceLevel: json['price_level'],
      openNow: json['opening_hours'] != null
          ? json['opening_hours']['open_now']
          : null,
      photoReference: (json['photos'] != null && json['photos'].isNotEmpty)
          ? json['photos'][0]['photo_reference']
          : null,
      iconUrl: json['icon'],
      plusCode:
          json['plus_code'] != null ? json['plus_code']['compound_code'] : null,
    );
  }

  /// Converts this [Place] instance into a JSON map.
  ///
  /// Useful for serialization and data storage.
  Map<String, dynamic> toJson() => {
        'name': name,
        'place_id': placeId,
        'business_status': businessStatus,
        'latitude': latitude,
        'longitude': longitude,
        'vicinity': address,
        'types': types,
        'rating': rating,
        'user_ratings_total': userRatingsTotal,
        'price_level': priceLevel,
        'open_now': openNow,
        'photo_reference': photoReference,
        'icon': iconUrl,
        'plus_code': plusCode,
      };

  /// Returns a string representation of the price level as dollar signs.
  ///
  /// For example, a `priceLevel` of 3 will return `$$$`. If null, returns `'N/A'`.
  String formattedPriceLevel() {
    if (priceLevel == null) return 'N/A';
    return '\$' * priceLevel!;
  }

  /// Returns a user-friendly string representing the open/closed status of the place.
  ///
  /// If [openNow] is true, returns `'Open Now'`. If false, returns `'Closed'`.
  /// If null, returns `'Unknown Hours'`.
  String openStatus() {
    if (openNow == null) return 'Unknown Hours';
    return openNow! ? 'Open Now' : 'Closed';
  }

  /// Generates a URL to retrieve the place's thumbnail photo from the Google Places API.
  ///
  /// Requires a valid [apiKey]. Returns `null` if no [photoReference] is available.
  String? thumbnailPhotoUrl(String apiKey) {
    if (photoReference == null) return null;
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=400&photo_reference=$photoReference&key=$apiKey';
  }

  /// Returns a readable string of place types with proper capitalization.
  ///
  /// For example, ["tourist_attraction", "museum"] becomes `"Tourist attraction, Museum"`.
  /// If no types are available, returns `'Unknown Type'`.
  String formattedTypes() {
    if (types.isEmpty) return 'Unknown Type';
    return types.map((t) => t.replaceAll('_', ' ').capitalize()).join(', ');
  }

  /// Returns a summary of the rating and total user reviews.
  ///
  /// For example: `"4.5 ★ (120 reviews)"`.
  String ratingSummary() {
    return '$rating ★ ($userRatingsTotal reviews)';
  }
}

/// Extension on [String] to provide basic casing utilities.
extension StringCasingExtension on String {
  /// Capitalizes the first letter of the string, leaving the rest unchanged.
  ///
  /// Example: `"museum".capitalize()` → `"Museum"`.
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
