// This file is to obtain the current location of the user.
// Do not access any location specific services until the .ready(config) method is done running.
// If you are using this service for the current location. The sole variable of interest to you is the "currentLocation" variable

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class LocationService {

  // If you are using this service, this is the sole variable you care about. Just access this.
  late bg.Location currentLocation;

  // This is the private constructor.
  LocationService._internal();

  // Instance of the singleton pattern.
  static final LocationService _instance = LocationService._internal(); // Eager initialization.

  // Factory to give out instance (always the same instance).
  factory LocationService() {
    return _instance;
  }

  // This function is to initialize the listening for current location service. It needs to be run first.
  Future<void> startListeningForLocation() async {
    try {

      // Listen for location updates asynchronously.
      bg.BackgroundGeolocation.onLocation((bg.Location location) {
        currentLocation = location;
      });

      // Listen for motion state changes asynchronously.
      bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
        currentLocation = location;
      });

      // Listen for provider changes asynchronously.
      bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
        print('[providerchange] - $event');
      });

      // Configure the plugin asynchronously.
      final state = await bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      ));

      // If the service is not enabled, start it asynchronously.
      if (!state.enabled) {
        await bg.BackgroundGeolocation.start();
      }

    } catch (e) {
      print("Error initializing location service: $e");
    }
  }

  void takeLocation(bg.Location location){
    currentLocation = location;
  }



} //end of class
