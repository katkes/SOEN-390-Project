import 'dart:async';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';

/// Service for managing location-related functionality.
///
/// This class provides methods for determining permissions, retrieving the
/// current location, updating the location, and creating a location stream.
/// It uses the singleton pattern to ensure only one instance exists.
class LocationService {
  // Private static instance variable
  static LocationService? _instance;

  // Static getter for the singleton instance
  static LocationService get instance {
     _instance ??=
         LocationService._internal(geolocator: geo.GeolocatorPlatform.instance);
    return _instance!;
  }

  // Factory constructor that returns the singleton instance
  factory LocationService({required geo.GeolocatorPlatform geolocator}) {
     _instance ??= LocationService._internal(geolocator: geolocator);
    return _instance!;
  }

  /// Private constructor
  /// Creates a [LocationService] instance with dependency injection.
  ///
  /// The [geolocator] parameter is required and provides the platform-specific
  /// implementation for location services.
  LocationService._internal({required this.geolocator});

  final geo.GeolocatorPlatform geolocator;

  bool _isLocSettingInitialized = false;
  late geo.Position currentPosition;
  late final geo.LocationSettings locSetting;
  StreamSubscription<geo.Position>? _positionStream;
  bool serviceEnabled = false;

  /// The current location permission status.
  geo.LocationPermission permission = geo.LocationPermission.denied;

  Future<bool> isLocationEnabled() async {
    return await geolocator.isLocationServiceEnabled();
  }

  /// Determines if location services and permissions are enabled.
  Future<bool> determinePermissions() async {
    serviceEnabled = await geolocator.isLocationServiceEnabled();
    print("Service Enabled: $serviceEnabled");

    permission = await geolocator.checkPermission();
    print("Initial Permission: $permission");

    if (permission == geo.LocationPermission.denied) {
      permission = await geolocator.requestPermission();
      print("Requested Permission: $permission");
    }

    if (permission == geo.LocationPermission.deniedForever) {
      print("Permissions denied forever.");
      return false;
    }

    if (permission == geo.LocationPermission.denied) {
      geo.Position? position = await geolocator.getLastKnownPosition();
      if (position != null) {
        currentPosition = position;
      }
      return false;
    }

    return serviceEnabled && permission != geo.LocationPermission.denied;
  }

  /// Retrieves the current location with low accuracy.
  Future<geo.Position> getCurrentLocation() async {
    return await geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.low,
      ),
    );
  }

  /// Updates the `currentPosition` with low accuracy.
  Future<void> updateCurrentLocation() async {
    currentPosition = await geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.low,
      ),
    );
  }

  /// Retrieves the current location with high accuracy.
  Future<geo.Position> getCurrentLocationAccurately() async {
    return await geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.best,
      ),
    );
  }

  /// Updates the `currentPosition` with high accuracy.
  Future<void> updateCurrentLocationAccurately() async {
    currentPosition = await geolocator.getCurrentPosition(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.best,
      ),
    );
  }

  /// Manually sets the current position.
  void takePosition(geo.Position p) {
    currentPosition = p;
  }

  /// Initializes platform-specific location settings.
  void setPlatformSpecificLocationSettings() {
    if (_isLocSettingInitialized) return;
    _isLocSettingInitialized = true;

    locSetting = const geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 4,
    );
  }

  /// Creates a location stream for continuous updates.
  void createLocationStream() {
    _positionStream = geolocator
        .getPositionStream(locationSettings: locSetting)
        .listen((geo.Position position) {
      currentPosition = position;
    });
  }

  //same method as above, but this one will return you the position object instead.
  // Future<geo.Position> createLocationStreamReturn() {
  //   _positionStream = geolocator
  //       .getPositionStream(locationSettings: locSetting)
  //       .listen((geo.Position position) {
  //     return position;
  //   });
  // }

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

  /// Returns the closest campus to the current location.
  /// Made static to allow direct calls without an instance.
  static String getClosestCampus(geo.Position currentPosition) {
    var campusCoordinates = {
      "SGW": [45.4973, -73.5784],
      "LOY": [45.4586, -73.6401]
    };

    double distanceToSGW = geo.Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      campusCoordinates["SGW"]![0],
      campusCoordinates["SGW"]![1],
    );
    double distanceToLOY = geo.Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      campusCoordinates["LOY"]![0],
      campusCoordinates["LOY"]![1],
    );

    return (distanceToSGW <= distanceToLOY) ? "SGW" : "LOY";
  }

  // Reset the instance for testing purposes
  static void resetInstance() {
    _instance = null;
  }

  /// Provides a stream of position updates.
  /// Ensures encapsulation by preventing direct access to `geolocator`.
  Stream<geo.Position> getPositionStream() {
    if (!_isLocSettingInitialized) {
      setPlatformSpecificLocationSettings();
    }
    return geolocator.getPositionStream(locationSettings: locSetting);
  }

  LatLng convertPositionToLatLng(geo.Position p) {
    return new LatLng(p.latitude, p.longitude);
  }

}
