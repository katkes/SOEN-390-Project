// This file uses the geolocator package to provide location fetching services
// It contains a single class with many methods and variables.
// =========================================================================================================================
// IF YOU ONLY WANT TO USE THESE FUNCTIONALITIES, USE THE VARIABLE "currentPosition", this is the only thing you care about.
// =========================================================================================================================

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:soen_390/utils/PermissionNotEnabledException.dart';

class LocationService {
  //this is the variable which will contain the current position. Anytime you use this class services, refer to this variable.
  late Position currentPosition;
  //constructor
  LocationService._internal();
  //Singleton eager initialization
  static final LocationService _instance = LocationService._internal();
  //platform specific settings initialized
  late final LocationSettings locSetting;
  //stream object which listens to movement events to update location
  StreamSubscription<Position>? _positionStream;

  //factory method designed for giving out the same instance.
  factory LocationService() {
    return _instance;
  }

  //validate permissions. If permissions are denied, ask, if still doesn't work, use the last known location.
  //returning true = permissions are allowed
  //returning false = permissions are denied. This is regardless of if currentPosition gets set with last known position
  Future<bool> determinePermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    //check if the device even has a location feature thing (most will, so im not really worried)
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission(); //check if the permission is denied.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); //ask if denied
      if (permission == LocationPermission.denied) { //if its denied again
        //use the latest known position (better than anything ig?)
        Position? position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          currentPosition = position;
          return false;
        } else {
          return Future.error('Location permissions are denied');
        }
      }
    }//end of if statement blocks.
    // last thing we check because the user could have enabled permission beforehand
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, Unable to request permissions.');
    }
    return true;
  }//end of determinePermissions method

  //returns the current position at a given point in time. low accuracy
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
       //we only want an estimate. Which is why low is used.
       desiredAccuracy: LocationAccuracy.low, //we dont need best, this is only for campus selection at the beginning
       forceAndroidLocationManager: true,
     );
  }
  //updates currentPosition at a given point in time. low accuracy
  Future<void> updateCurrentLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
  }
  //returns the current position at a given point in time. high accuracy
  Future<Position> getCurrentLocationAccurately() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best, //The best the device can do
      forceAndroidLocationManager: true,
    );
  }
  //updates currentPosition at a given point in time. high accuracy
  Future<void> updateCurrentLocationAccurately() async {
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best, //The best the device can do
      forceAndroidLocationManager: true,
    );
  }

  //sets the current position to a value
  void takePosition(Position p){
    currentPosition = p;
  }

  //sets platform specific locations depending on the OS of the device. Does not support web.
  void setPlatformSpecificLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locSetting = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 4, //number of meters until location updates again.
          forceLocationManager: true, //forces to use the legacy code instead of the newer one. Bunch of places say its better?
          intervalDuration: const Duration(seconds: 10),
          //keeps app alive when in background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Concordia navigation app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true, //if system sleeps, this makes sure all the notification events dont come crashing in all at once
          )
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locSetting = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 4,
        pauseLocationUpdatesAutomatically: true,
        //keep this false because our app wont start up in the background. User needs to open it.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locSetting = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4,
      );
    }
  } //end of function

  //continuously listens to movement events to update the location after a certain amount of distance has been traveled.
  void createLocationStream() {
    _positionStream = Geolocator.getPositionStream(locationSettings: locSetting)
        .listen((Position position) {
      currentPosition = position; //stream should always update the actual currentPosition object
    });
  }

  //starts up by determining permissions, then setting location settings and finally creating the location stream
  void startUp() async{
    bool locationEnabled = await _instance.determinePermissions();
    if (locationEnabled == true){
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
