import 'dart:async';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
import 'package:geolocator/geolocator.dart';

/// Service for managing location-related functionality.
///
/// This class provides methods for determining permissions, retrieving the
/// current location, updating the location, and creating a location stream.
class LocationService {
  final GeolocatorPlatform geolocator;

  bool _isLocSettingInitialized = false;
  late Position currentPosition;
  late final LocationSettings locSetting;
  StreamSubscription<Position>? _positionStream;
  bool serviceEnabled = false;
  LocationPermission permission = LocationPermission.denied;

  /// Creates a [LocationService] instance with dependency injection.
  LocationService({required this.geolocator});

  Future<bool> isLocationEnabled() async {
    return await geolocator.isLocationServiceEnabled();
  }

  /// Determines if location services and permissions are enabled.
  Future<bool> determinePermissions() async {
    serviceEnabled = await geolocator.isLocationServiceEnabled();
    print("Service Enabled: $serviceEnabled");

    permission = await geolocator.checkPermission();
    print("Initial Permission: $permission");

    if (permission == LocationPermission.denied) {
      permission = await geolocator.requestPermission();
      print("Requested Permission: $permission");
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permissions denied forever.");
      return false;
    }

    if (permission == LocationPermission.denied) {
      Position? position = await geolocator.getLastKnownPosition();
      if (position != null) {
        currentPosition = position;
      }
      return false;
    }

    return serviceEnabled && permission != LocationPermission.denied;
  }

  /// Retrieves the current location with low accuracy.
  Future<Position> getCurrentLocation() async {
    return await geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );
  }

  /// Updates the `currentPosition` with low accuracy.
  Future<void> updateCurrentLocation() async {
    currentPosition = await geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );
  }

  /// Retrieves the current location with high accuracy.
  Future<Position> getCurrentLocationAccurately() async {
    return await geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );
  }

  /// Updates the `currentPosition` with high accuracy.
  Future<void> updateCurrentLocationAccurately() async {
    currentPosition = await geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
      ),
    );
  }

  /// Manually sets the current position.
  void takePosition(Position p) {
    currentPosition = p;
  }

  /// Initializes platform-specific location settings.
  void setPlatformSpecificLocationSettings() {
    if (_isLocSettingInitialized) return;
    _isLocSettingInitialized = true;

    locSetting = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 4,
    );
  }

  /// Creates a location stream for continuous updates.
  void createLocationStream() {
    _positionStream = geolocator
        .getPositionStream(locationSettings: locSetting)
        .listen((Position position) {
      currentPosition = position;
    });
  }

  /// Starts up location services, ensuring permissions and settings are set.
  Future<void> startUp() async {
    bool locationEnabled = await determinePermissions();
    if (locationEnabled) {
      setPlatformSpecificLocationSettings();
      createLocationStream();
    } else {
      throw PermissionNotEnabledException();
    }
  }

  /// Stops the location stream.
  void stopListening() {
    _positionStream?.cancel();
  }

  /// Provides a stream of position updates.
  /// Ensures encapsulation by preventing direct access to `geolocator`.
  Stream<Position> getPositionStream() {
    if (!_isLocSettingInitialized) {
      setPlatformSpecificLocationSettings();
    }
    return geolocator.getPositionStream(locationSettings: locSetting);
  }
}
