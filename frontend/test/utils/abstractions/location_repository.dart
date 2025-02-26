import 'package:geolocator/geolocator.dart';

/// Interface for location services.
///
/// This abstract class defines the contract for location-related functionality,
/// including determining permissions, retrieving the current location, and
/// creating a location stream.
abstract class ILocationRepository {
  /// Determines if location services and permissions are enabled.
  Future<bool> determinePermissions();

  /// Retrieves the current location.
  Future<Position> getCurrentLocation();

  /// Updates the current location.
  Future<void> updateCurrentLocation();

  /// Creates a stream for continuous location updates.
  Stream<Position> getPositionStream(LocationSettings settings);
}
