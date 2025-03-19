import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/services/building_info_api.dart';

/// A factory class responsible for creating [PointOfInterest] instances
/// by fetching place details from a remote API.
///
/// Uses a [GoogleMapsApiClient] to retrieve detailed information
/// about a place given its unique `placeId`, and constructs a
/// fully populated [PointOfInterest] object from it.
class PointOfInterestFactory {
  /// The API client used to fetch place details from Google Maps or other sources.
  final GoogleMapsApiClient apiClient;

  /// Constructs a [PointOfInterestFactory] with the given [apiClient].
  ///
  /// The [apiClient] is typically an instance of [GoogleMapsApiClient]
  /// which provides methods for querying place details.
  PointOfInterestFactory({required this.apiClient});

  /// Asynchronously creates a [PointOfInterest] by fetching place details using [placeId].
  ///
  /// The [imageUrl] parameter is required and should typically be derived
  /// from a photo reference obtained from the place API. This image URL will be
  /// associated with the created [PointOfInterest].
  ///
  /// Returns a [Future] that completes with the fully populated [PointOfInterest].
  ///
  /// Example:
  /// ```dart
  /// final poi = await poiFactory.createPointOfInterest(
  ///   placeId: 'abc123',
  ///   imageUrl: 'https://example.com/image.jpg',
  /// );
  /// ```
  Future<PointOfInterest> createPointOfInterest({
    required String placeId,
    required String imageUrl,
  }) async {
    print(
        'Creating PointOfInterest with placeId: $placeId and imageUrl: $imageUrl');

    // Fetch detailed information about the place using the provided placeId.
    final result = await apiClient.fetchPlaceDetailsById(placeId);
    print('Fetched place details: $result');

    // Create and return a PointOfInterest using the fetched details and image URL.
    final pointOfInterest =
        PointOfInterest.fromPlaceDetails(result, imageUrl: imageUrl);
    print('Created PointOfInterest: $pointOfInterest');

    return pointOfInterest;
  }
}
