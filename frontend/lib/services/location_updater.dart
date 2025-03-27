import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart';

/// A utility class that provides a simplified interface for retrieving
/// the user's current location as a [LatLng] object.
///
/// It initializes the [LocationService], fetches the user's position
/// using high accuracy, and converts it to a format suitable for map usage.
///
/// Example usage:
/// ```dart
/// final updater = LocationUpdater(locationService);
/// final currentLocation = await updater.getCurrentLatLng();
/// ```
class LocationUpdater {
  /// The underlying location service used for fetching the device's position.
  final LocationService service;

  /// Creates a [LocationUpdater] with the given [LocationService].
  LocationUpdater(this.service);

  /// Retrieves the user's current location as a [LatLng].
  ///
  /// This method:
  /// - Calls [LocationService.startUp()] to ensure location services are initialized.
  /// - Retrieves a high-accuracy location using [getCurrentLocationAccurately()].
  /// - Converts the position to a [LatLng] using [convertPositionToLatLng()].
  ///
  /// Returns:
  /// - A [LatLng] representing the user's current location.
  ///
  /// Throws:
  /// - Any exception thrown by the underlying [LocationService] if location access fails.
  Future<LatLng> getCurrentLatLng() async {
    await service.startUp();
    final position = await service.getCurrentLocationAccurately();
    return service.convertPositionToLatLng(position);
  }
}
