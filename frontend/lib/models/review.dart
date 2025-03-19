/// Represents a user-generated review, typically retrieved from an API.
///
/// The [Review] class encapsulates all the data related to a review such as
/// the author's name and profile, rating, time of posting, and the review text.
/// This model also provides methods to serialize and deserialize from JSON.
class Review {
  /// The name of the review author.
  final String authorName;

  /// The URL linking to the author's profile.
  final String authorUrl;

  /// The URL of the author's profile photo.
  final String profilePhotoUrl;

  /// The numerical star rating given in the review (typically 1–5).
  final int rating;

  /// A human-readable relative time description (e.g., "2 days ago").
  final String relativeTimeDescription;

  /// The text content of the review.
  final String text;

  /// The time the review was posted, represented as a [DateTime] object.
  final DateTime time;

  /// Constructs a [Review] with all required fields.
  ///
  /// All parameters are required and should not be null.
  Review({
    required this.authorName,
    required this.authorUrl,
    required this.profilePhotoUrl,
    required this.rating,
    required this.relativeTimeDescription,
    required this.text,
    required this.time,
  });

  /// Creates a [Review] instance from a JSON [Map].
  ///
  /// This factory constructor parses data typically received from an API response.
  /// It safely handles missing fields by providing default values.
  ///
  /// Example:
  /// ```dart
  /// final review = Review.fromJson(jsonMap);
  /// ```
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'] ?? '',
      authorUrl: json['author_url'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? '',
      rating: json['rating'] ?? 0,
      relativeTimeDescription: json['relative_time_description'] ?? '',
      text: json['text'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch((json['time'] ?? 0) * 1000),
    );
  }

  /// Converts the [Review] instance into a JSON [Map].
  ///
  /// This method is typically used when sending data back to an API
  /// or for local persistence (e.g., in shared preferences or a database).
  ///
  /// Note: The [time] field is converted to seconds since epoch for compatibility.
  Map<String, dynamic> toJson() {
    return {
      'author_name': authorName,
      'author_url': authorUrl,
      'profile_photo_url': profilePhotoUrl,
      'rating': rating,
      'relative_time_description': relativeTimeDescription,
      'text': text,
      'time': time.millisecondsSinceEpoch ~/ 1000, // Convert to seconds
    };
  }
}

/// Parses a list of reviews from a JSON array.
///
/// Takes a [List<dynamic>] typically obtained from an API response and
/// converts it into a list of [Review] objects.
///
/// Example:
/// ```dart
/// final reviews = parseReviews(jsonList);
/// ```
///
/// Returns a list of [Review] instances.
List<Review> parseReviews(List<dynamic> reviewsJson) {
  return reviewsJson.map((json) => Review.fromJson(json)).toList();
}
