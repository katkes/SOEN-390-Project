import 'package:geolocator/geolocator.dart';

/// Interface for location services
abstract class ILocationRepository {
  Future<bool> determinePermissions();
  Future<Position> getCurrentLocation();
  Future<void> updateCurrentLocation();
  Stream<Position> getPositionStream(LocationSettings settings);
}
