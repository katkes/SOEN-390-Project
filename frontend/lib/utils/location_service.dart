import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/foundation.dart';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';

class LocationService {
  final geo.GeolocatorPlatform geolocator;

  // Ensures platform-specific settings are initialized only once
  bool _isLocSettingInitialized = false;

  // This variable contains the current position; always refer to this when using this class
  late geo.Position currentPosition;

  // Platform-specific settings (late final ensures it's initialized only once)
  late final geo.LocationSettings locSetting;

  // Stream for tracking location changes
  StreamSubscription<geo.Position>? _positionStream;

  // Default state variables
  bool serviceEnabled = false;
  geo.LocationPermission permission = geo.LocationPermission.denied;

  // Constructor using dependency injection
  LocationService({required this.geolocator});

  // Determines if location services & permissions are enabled
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

  // Gets current position (low accuracy)
  Future<geo.Position> getCurrentLocation() async {
    return await geolocator.getCurrentPosition(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.low,
      ),
    );
  }

  // Updates `currentPosition` (low accuracy)
  Future<void> updateCurrentLocation() async {
    currentPosition = await geolocator.getCurrentPosition(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.low,
      ),
    );
  }

  // Gets current position (high accuracy)
  Future<geo.Position> getCurrentLocationAccurately() async {
    return await geolocator.getCurrentPosition(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.best,
      ),
    );
  }

  // Updates `currentPosition` (high accuracy)
  Future<void> updateCurrentLocationAccurately() async {
    currentPosition = await geolocator.getCurrentPosition(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.best,
      ),
    );
  }

  // Manually sets the current position
  void takePosition(geo.Position p) {
    currentPosition = p;
  }

  // Initializes platform-specific location settings
  void setPlatformSpecificLocationSettings() {
    if (_isLocSettingInitialized) return;
    _isLocSettingInitialized = true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locSetting = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 4,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locSetting = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 4,
      );
    } else {
      locSetting = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 4,
      );
    }
  }

  // Creates a location stream for continuous updates
  void createLocationStream() {
    _positionStream = geolocator
        .getPositionStream(locationSettings: locSetting)
        .listen((geo.Position position) {
      currentPosition = position;
    });
  }

  // Starts up location services, ensuring permissions and settings are set
  Future<void> startUp() async {
    bool locationEnabled = await determinePermissions();
    if (locationEnabled) {
      setPlatformSpecificLocationSettings();
      createLocationStream();
    } else {
      throw PermissionNotEnabledException();
    }
  }

  // Stops the location stream
  void stopListening() {
    _positionStream?.cancel();
  }
}
