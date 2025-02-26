// This file uses the geolocator package to provide location fetching services
// It contains a single class with many methods and variables.
// =========================================================================================================================
// IF YOU ONLY WANT TO USE THESE FUNCTIONALITIES, USE THE VARIABLE "currentPosition", this is the only thing you care about.
// =========================================================================================================================

import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/foundation.dart';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';


class LocationService {
  //this is the variable which will contain the current position. Anytime you use this class services, refer to this variable.
  late geo.Position currentPosition;
  //constructor
  LocationService._internal();
  //Singleton eager initialization
  static final LocationService _instance = LocationService._internal();
  //platform specific settings initialized
  late final geo.LocationSettings locSetting;
  //stream object which listens to movement events to update location
  StreamSubscription<geo.Position>? _positionStream;

  bool serviceEnabled = false;  //by default, it will be false.
  geo.LocationPermission permission = geo.LocationPermission.denied; //default should be denied.

  //factory method designed for giving out the same instance.
  factory LocationService() {
    return _instance;
  }

  //validate permissions. If permissions are denied, ask, if still doesn't work, use the last known location.
  //returning true = permissions are allowed
  //returning false = permissions are denied. This is regardless of if currentPosition gets set with last known position
  Future<bool> determinePermissions() async {
    //check if the device even has a location feature thing (most will, so im not really worried)
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
      // alternatively, you can return an error like so:
      // return Future.error('Location services are disabled.');
    }
    permission =
        await geo.Geolocator.checkPermission(); //check if the permission is denied.
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission(); //ask if denied
      if (permission == geo.LocationPermission.denied) {
        //if its denied again
        //use the latest known position (better than anything ig?)
        geo.Position? position = await geo.Geolocator.getLastKnownPosition();
        if (position != null) {
          currentPosition = position;
          return false;
        } else {
          return false;
          // alternatively, you can return an error like so:
          // return Future.error('Location permissions are denied');
        }
      }
    } //end of if statement blocks.
    // last thing we check because the user could have enabled permission beforehand
    if (permission == geo.LocationPermission.deniedForever) {
      return false;
      // alternatively, you can return a future error like so:
      // return Future.error('Location permissions are permanently denied, Unable to request permissions.');
    }
    return true;
  } //end of determinePermissions method

  //returns the current position at a given point in time. low accuracy
  Future<geo.Position> getCurrentLocation() async {
    return await geo.Geolocator.getCurrentPosition(
      //we only want an estimate. Which is why low is used.
      desiredAccuracy: geo.LocationAccuracy
          .low, //we dont need best, this is only for campus selection at the beginning
      forceAndroidLocationManager: true,
    );
  }

  //updates currentPosition at a given point in time. low accuracy
  Future<void> updateCurrentLocation() async {
    currentPosition = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
  }

  //returns the current position at a given point in time. high accuracy
  Future<geo.Position> getCurrentLocationAccurately() async {
    return await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.best, //The best the device can do
      forceAndroidLocationManager: true,
    );
  }

  //updates currentPosition at a given point in time. high accuracy
  Future<void> updateCurrentLocationAccurately() async {
    currentPosition = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.best, //The best the device can do
      forceAndroidLocationManager: true,
    );
  }

  //sets the current position to a value
  void takePosition(geo.Position p) {
    currentPosition = p;
  }

  //sets platform specific locations depending on the OS of the device. Does not support web.
  void setPlatformSpecificLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locSetting = geo.AndroidSettings(
          accuracy: geo.LocationAccuracy.high,
          distanceFilter: 4, //number of meters until location updates again.
          forceLocationManager:
              true, //forces to use the legacy code instead of the newer one. Bunch of places say its better?
          intervalDuration: const Duration(seconds: 10),
          //keeps app alive when in background
          foregroundNotificationConfig: const geo.ForegroundNotificationConfig(
            notificationText:
                "Concordia navigation app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock:
                true, //if system sleeps, this makes sure all the notification events dont come crashing in all at once
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locSetting = geo.AppleSettings(
        accuracy: geo.LocationAccuracy.high,
        activityType: geo.ActivityType.fitness,
        distanceFilter: 4,
        pauseLocationUpdatesAutomatically: true,
        //keep this false because our app wont start up in the background. User needs to open it.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locSetting = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 4,
      );
    }
  } //end of function

  //continuously listens to movement events to update the location after a certain amount of distance has been traveled.
  void createLocationStream() {
    _positionStream = geo.Geolocator.getPositionStream(locationSettings: locSetting)
        .listen((geo.Position position) {
      currentPosition =
          position; //stream should always update the actual currentPosition object
    });
  }

  //starts up by determining permissions, then setting location settings and finally creating the location stream
  void startUp() async {
    bool locationEnabled = await _instance.determinePermissions();
    if (locationEnabled == true) {
      _instance.setPlatformSpecificLocationSettings();
      _instance.createLocationStream();
    } else {
      throw PermissionNotEnabledException();
    }
  }

  //removes the stream.
  void stopListening() {
    _positionStream?.cancel();
  }
} //end of class
