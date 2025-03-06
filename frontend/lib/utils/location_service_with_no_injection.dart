import 'dart:async';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationServiceWithNoInjection{

  late Position currentPosition;
  LocationServiceWithNoInjection._internal();
  static LocationServiceWithNoInjection instance = LocationServiceWithNoInjection._internal();
  late final LocationSettings locSetting;
  StreamSubscription<Position>? _positionStream;

  bool serviceEnabled = false;
  LocationPermission permission = LocationPermission.denied;
  factory LocationServiceWithNoInjection() {
    return instance;
  }

  Future<bool> determinePermissions() async {

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission =
    await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Position? position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          currentPosition = position;
          return false;
        } else {
          return false;
        }
      }
    } //end of if statement blocks.
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  } //end of determinePermissions method

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
  }

  Future<void> updateCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
  }

  Future<Position> getCurrentLocationAccurately() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true,
    );
  }

  Future<void> updateCurrentLocationAccurately() async {
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true,
    );
  }

  void takePosition(Position p) {
    currentPosition = p;
  }

  void setPlatformSpecificLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locSetting = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 4,
          forceLocationManager:
          true,
          intervalDuration: const Duration(seconds: 10),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Concordia navigation app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock:
            true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locSetting = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 4,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      locSetting = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4,
      );
    }
  } //end of function

  //continuously listens to movement events to update the location after a certain amount of distance has been traveled.
  void createLocationStream() {
    _positionStream = Geolocator.getPositionStream(locationSettings: locSetting)
        .listen((Position position) {
      currentPosition =
          position; //stream should always update the actual currentPosition object
    });
  }

  void startUp() async {
    bool locationEnabled = await instance.determinePermissions();
    if (locationEnabled == true) {
      instance.setPlatformSpecificLocationSettings();
      instance.createLocationStream();
    } else {
      throw PermissionNotEnabledException();
    }
  }


  void stopListening() async {
    await _positionStream?.cancel();
  }

  StreamSubscription<Position>? getStreamobj() {
    return _positionStream;
  }



} //end of class