import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter/material.dart'; //need to import this all the time because flutter classes like statefulwidget dont exist naturally in flutter. You need to import it. You're coding in dart, not flutter




//This file is to obtain the current location of the user.
// Do not access any location specific services until the .ready(config) method is done running.


class LocationService {

  // If you are using this service, this is the sole variable you care about. Just access this.
  bg.Location? currentLocation;

  //instance of the singleton pattern.
  static final LocationService _instance = LocationService._internal();

  //this is the private constructor.
  LocationService._internal();

  //factory to give out instance.
  factory LocationService() {
    return _instance;
  }

  void getUserLocation(){

    //listen to events here
    // Fired whenever a location is recorded
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      currentLocation = location;
    });
    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      currentLocation = location;
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    //Configure the plugin
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });
  }
}


