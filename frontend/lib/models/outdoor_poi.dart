import 'package:soen_390/models/review.dart';

/// Represents a location or establishment of potential interest to users,
/// such as a restaurant, park, or store. Includes identification, contact
/// information, category, reviews, and more.
class PointOfInterest {
  /// Unique identifier for the point of interest, typically from a place API.
  final String id;

  /// Name of the point of interest (e.g., "Joe's Cafe").
  final String name;

  /// Brief textual description or overview of the point of interest.
  final String description;

  /// Optional URL to an image representing the point of interest.
  final String? imageUrl;

  /// Optional physical address of the location.
  final String? address;

  /// Optional contact phone number.
  final String? contactPhone;

  /// Optional website URL.
  final String? website;

  /// Optional map of opening hours for each weekday (e.g., {'Monday': '9AM–5PM'}).
  final Map<String, String>? openingHours;

  /// Optional list of amenities provided (e.g., ['Wi-Fi', 'Wheelchair Accessible']).
  final List<String>? amenities;

  /// Optional average user rating (e.g., 4.5).
  final double? rating;

  /// Optional category describing the type of location (e.g., 'Restaurant').
  final String? category;

  /// Optional price range indicated by dollar signs (e.g., '$$', '$$$').
  final String? priceRange;

  /// Optional list of user reviews.
  final List<Review>? reviews;

  /// Latitude of the point of interest.
  final double latitude;

  /// Longitude of the point of interest.
  final double longitude;

  /// Constructs a [PointOfInterest] with the given required and optional fields.
  const PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.address,
    this.contactPhone,
    this.website,
    this.openingHours,
    this.amenities,
    this.rating,
    this.category,
    this.priceRange,
    this.reviews,
  });

  /// Factory constructor to create a [PointOfInterest] from raw JSON data.
  ///
  /// Parses the top-level 'result' object, extracts photo references, constructs
  /// an image URL if available, and delegates to [fromPlaceDetails].
  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    print('Parsing JSON to PointOfInterest...');
    final result = json['result'];
    print('Result: $result');

    final photoList = result['photos'] as List?;
    print('Photo List: $photoList');

    final imageUrl = photoList != null && photoList.isNotEmpty
        ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoList[0]['photo_reference']}&key=YOUR_API_KEY"
        : null;

    print('Image URL: $imageUrl');

    return PointOfInterest.fromPlaceDetails(result, imageUrl: imageUrl ?? '');
  }

  /// Factory constructor to create a [PointOfInterest] from detailed place data.
  ///
  /// Extracts relevant fields, formats opening hours, amenities, and category,
  /// and parses reviews. Accepts a required [imageUrl], typically constructed
  /// externally from photo references.
  factory PointOfInterest.fromPlaceDetails(Map<String, dynamic> result,
      {required String imageUrl}) {
    print('Parsing Place Details to PointOfInterest...');

    final typesList = _parseTypesList(result);
    print('Types List: $typesList');

    final formattedCategory = _getFormattedCategory(typesList);
    final openingHoursMap = _parseOpeningHours(result);
    final amenitiesList = _parseAmenities(result);
    final parsedReviews = _parseReviewsIfAvailable(result);
    final priceRange = _parsePriceRange(result);

    final location = result['geometry']?['location'];
    final latitude = (location?['lat'] as num?)?.toDouble() ?? 0.0;
    final longitude = (location?['lng'] as num?)?.toDouble() ?? 0.0;

    return PointOfInterest(
      id: result['place_id'] ?? '',
      name: result['name'] ?? '',
      description: result['editorial_summary']?['overview'] ?? '',
      imageUrl: imageUrl,
      address: result['formatted_address'],
      contactPhone: result['formatted_phone_number'],
      website: result['website'],
      openingHours: openingHoursMap,
      amenities: amenitiesList.isEmpty ? null : amenitiesList,
      rating: (result['rating'] as num?)?.toDouble(),
      category: formattedCategory,
      priceRange: priceRange,
      reviews: parsedReviews,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Parses the 'types' field from [result] and returns it as a [List<String>].
  /// If the field is absent or null, returns an empty list.
  static List<String> _parseTypesList(Map<String, dynamic> result) {
    return result['types'] != null
        ? (result['types'] as List).cast<String>()
        : <String>[];
  }

  /// Filters the provided [typesList] against a predefined set of allowed types,
  /// then formats it into a user-friendly category string if applicable.
  ///
  /// Returns `null` if no matching type is found.
  static String? _getFormattedCategory(List<String> typesList) {
    const allowedTypes = [
      'restaurant',
      'store',
      'hospital',
      'bank',
      'transit_station',
      'lodging',
      'movie_theater',
      'park',
      'church',
      'school',
      'local_government_office',
      'car_repair',
      'beauty_salon',
      'tourist_attraction',
    ];

    final filteredType = typesList.firstWhere(
      (type) => allowedTypes.contains(type),
      orElse: () => '',
    );

    return filteredType.isNotEmpty ? prettifyCategory(filteredType) : null;
  }

  /// Parses the 'opening_hours' field in [result] and converts it into a
  /// [Map<String, String>] where the key is the weekday and the value is the hours.
  ///
  /// Returns `null` if parsing fails or if data is unavailable.
  static Map<String, String>? _parseOpeningHours(Map<String, dynamic> result) {
    final weekdayTextList = result['opening_hours']?['weekday_text'] as List?;
    if (weekdayTextList == null || weekdayTextList.isEmpty) return null;

    try {
      return {
        for (var e in weekdayTextList)
          if (e.toString().contains(':'))
            e.toString().split(':')[0]:
                e.toString().split(':').sublist(1).join(':').trim()
      };
    } catch (e) {
      print('Error parsing opening hours: $e');
      return null;
    }
  }

  /// Parses amenity-related boolean flags in [result] and returns a
  /// [List<String>] representing the available amenities (e.g., Beer, Wine).
  ///
  /// Returns an empty list if no amenities are found.
  static List<String> _parseAmenities(Map<String, dynamic> result) {
    final amenitiesList = <String>[];

    if (result['serves_beer'] == true) amenitiesList.add('Beer');
    if (result['serves_wine'] == true) amenitiesList.add('Wine');
    if (result['serves_vegetarian_food'] == true) {
      amenitiesList.add('Vegetarian');
    }
    if (result['takeout'] == true) amenitiesList.add('Takeout');
    if (result['wheelchair_accessible_entrance'] == true) {
      amenitiesList.add('Wheelchair Accessible');
    }

    return amenitiesList;
  }

  /// Parses the 'reviews' field from [result] and converts it into a list of
  /// [Review] objects using [parseReviews]. Returns `null` if no reviews are found.
  static List<Review>? _parseReviewsIfAvailable(Map<String, dynamic> result) {
    final reviewsJsonList = result['reviews'] as List?;
    return reviewsJsonList != null ? parseReviews(reviewsJsonList) : null;
  }

  /// Parses the 'price_level' integer from [result] and converts it into a
  /// string representation using dollar signs (e.g., "$$", "$$$").
  ///
  /// Returns `null` if price level is unavailable or not recognized.
  static String? _parsePriceRange(Map<String, dynamic> result) {
    final priceLevel = result['price_level'];
    switch (priceLevel) {
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        return null;
    }
  }
}

/// Converts a category string with underscores into a more human-readable format.
///
/// Example:
/// `'tourist_attraction'` → `'Tourist Attraction'`
String prettifyCategory(String type) {
  return type
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
