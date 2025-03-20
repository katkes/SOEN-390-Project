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

    print('Name: ${result['name']}');

    final typesList = result['types'] != null
        ? (result['types'] as List).cast<String>()
        : <String>[];

    print('Types List: $typesList');

    final filteredType = typesList.firstWhere(
      (type) => allowedTypes.contains(type),
      orElse: () => '',
    );

    String? formattedCategory;
    if (filteredType.isNotEmpty) {
      formattedCategory = prettifyCategory(filteredType);
    } else {
      formattedCategory = null;
    }

    // Parse opening hours if available
    final weekdayTextList = result['opening_hours']?['weekday_text'] as List?;
    Map<String, String>? openingHoursMap;
    if (weekdayTextList != null && weekdayTextList.isNotEmpty) {
      try {
        openingHoursMap = {
          for (var e in weekdayTextList)
            if (e.toString().contains(':'))
              e.toString().split(':')[0]:
                  e.toString().split(':').sublist(1).join(':').trim()
        };
      } catch (e) {
        print('Error parsing opening hours: $e');
        openingHoursMap = null;
      }
    }

    // Parse available amenities
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

    // Parse reviews if available
    final reviewsJsonList = result['reviews'] as List?;
    final parsedReviews =
        reviewsJsonList != null ? parseReviews(reviewsJsonList) : null;

    // Convert price level integer to dollar signs
    String? priceRange;
    final priceLevel = result['price_level'];
    if (priceLevel != null) {
      switch (priceLevel) {
        case 1:
          priceRange = '\$';
          break;
        case 2:
          priceRange = '\$\$';
          break;
        case 3:
          priceRange = '\$\$\$';
          break;
        case 4:
          priceRange = '\$\$\$\$';
          break;
      }
    }
    // Extract latitude and longitude
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
