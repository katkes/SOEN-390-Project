import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/foundation.dart';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';

/// Service for managing location-related functionality.
///
/// This class provides methods for determining permissions, retrieving the
/// current location, updating the location, and creating a location stream.
class LocationService {
  final geo.GeolocatorPlatform geolocator;

  // Ensures platform-specific settings are initialized only once
  bool _isLocSettingInitialized = false;

  /// The current position of the device.
  ///
  /// This variable contains the latest known position and is updated
  /// whenever a new location is retrieved.
  late geo.Position currentPosition;

  /// Platform-specific location settings.
  ///
  /// These settings are initialized once and used for location updates.
  late final geo.LocationSettings locSetting;

  /// Stream subscription for tracking location changes.
  StreamSubscription<geo.Position>? _positionStream;

  /// Indicates whether location services are enabled.
  /// serviceEnabled and permission are set to false/denied because the initial assumption should be so
  /// Accessing location without having the permission will cause errors.
  /// This value gets updated once the application is opened.
  bool serviceEnabled = false;

  /// The current location permission status.
  geo.LocationPermission permission = geo.LocationPermission.denied;

  /// Creates a [LocationService] instance with dependency injection.
  ///
  /// The [geolocator] parameter is required and provides the platform-specific
  /// implementation for location services.
  LocationService({required this.geolocator});

  /// Determines if location services and permissions are enabled.
  ///
  /// Returns `true` if location services are enabled and permissions are granted,
  /// otherwise returns `false`.
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
  ///
  /// Returns a [geo.Position] object representing the current location.
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
  ///
  /// Returns a [geo.Position] object representing the current location.
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
  ///
  /// The [p] parameter is the [geo.Position] to set as the current position.
  void takePosition(geo.Position p) {
    currentPosition = p;
  }

  /// Initializes platform-specific location settings.
  ///
  /// This method ensures that location settings are initialized only once.
  void setPlatformSpecificLocationSettings() {
    if (_isLocSettingInitialized) return;
    _isLocSettingInitialized = true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locSetting = const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 4,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locSetting = const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 4,
      );
    } else {
      locSetting = const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 4,
      );
    }
  }

  /// Creates a location stream for continuous updates.
  ///
  /// This method initializes a stream that updates the `currentPosition`
  /// whenever the device's location changes.
  void createLocationStream() {
    _positionStream = geolocator
        .getPositionStream(locationSettings: locSetting)
        .listen((geo.Position position) {
      currentPosition = position;
    });
  }

  /// Starts up location services, ensuring permissions and settings are set.
  ///
  /// Throws a [PermissionNotEnabledException] if location services are disabled.
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
}
