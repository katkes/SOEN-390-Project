import 'package:flutter/material.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/screens/outdoor_poi/outdoor_poi_detail_screen.dart';
import 'package:soen_390/services/poi_factory.dart';

/// A handler class for managing what happens when a [Place] is tapped.
///
/// This class is responsible for:
/// - Generating a [PointOfInterest] using [PointOfInterestFactory]
/// - Navigating to a detailed POI screen
/// - Returning selected destination data (if any) to the calling context
/// - Handling errors with user-friendly feedback
///
/// Typically used in a map or list of nearby places.
///
/// Example usage:
/// ```dart
/// final handler = PlaceTapHandler(
///   context: context,
///   apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
///   poiFactory: PointOfInterestFactory(),
///   onSetDestination: (name, lat, lng) {
///     // Set as route destination
///   },
/// );
/// handler.handle(place);
/// ```
class PlaceTapHandler {
  /// The current [BuildContext], used for navigation and showing snackbars.
  final BuildContext context;

  /// Google Maps API key used for retrieving photos or place data.
  final String apiKey;

  /// Factory used to create [PointOfInterest] objects from [Place] data.
  final PointOfInterestFactory poiFactory;

  /// Optional callback triggered when a destination is selected from the detail screen.
  final void Function(String name, double lat, double lng)? onSetDestination;

  /// Constructs a [PlaceTapHandler] with the required dependencies.
  PlaceTapHandler({
    required this.context,
    required this.apiKey,
    required this.poiFactory,
    this.onSetDestination,
  });

  /// Handles the logic when a [Place] is tapped by the user.
  ///
  /// This method:
  /// - Fetches the photo URL and POI data for the selected place.
  /// - Navigates to the [PoiDetailScreen] to show additional information.
  /// - If the user selects a destination, invokes [onSetDestination].
  /// - Handles any errors gracefully by showing a [SnackBar].
  ///
  /// Parameters:
  /// - [place]: The tapped [Place] object from the list or map view.
  ///
  /// Returns:
  /// - A [Future] that completes once the flow finishes or is canceled.
  Future<void> handle(Place place) async {
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final imageUrl = place.thumbnailPhotoUrl(apiKey) ?? '';
      final poi = await poiFactory.createPointOfInterest(
        placeId: place.placeId,
        imageUrl: imageUrl,
      );

      final result = await navigator.push(
        MaterialPageRoute(builder: (_) => PoiDetailScreen(poi: poi)),
      );

      if (result != null && result is Map<String, dynamic>) {
        onSetDestination?.call(
          result['name'] as String,
          result['lat'] as double,
          result['lng'] as double,
        );
        navigator.pop(); // Navigate back
      }
    } catch (e) {
      scaffold.showSnackBar(
        const SnackBar(content: Text("Failed to load place details.")),
      );
    }
  }
}
