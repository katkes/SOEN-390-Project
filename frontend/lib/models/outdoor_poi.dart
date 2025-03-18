/// This class stores information about a location that may be of interest to users,
/// including identification, description, contact details, and categorical information.
// TODO: Add fromJson/toJson methods for API integration for task 6.1.2
class PointOfInterest {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? address;
  final String? contactPhone;
  final String? website;
  final Map<String, String>? openingHours;
  final List<String>? amenities;
  final double? rating;
  final String? category;
  final List<String>? cuisine;
  final Map<String, dynamic>? priceRange;

  const PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.address,
    this.contactPhone,
    this.website,
    this.openingHours,
    this.amenities,
    this.rating,
    this.category,
    this.cuisine,
    this.priceRange,
  });
}
