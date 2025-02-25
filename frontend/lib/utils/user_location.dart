
// This file uses the geolocator package to provide location fetching services
// It contains a single class with many methods and variables.
// IF YOU ONLY WANT TO USE THESE FUNCTIONALITIES, USE THE VARIABLE "currentPosition", this is the only thing you care about.

import 'package:geolocator/geolocator.dart';

//function for current location
//this is the "state"

class LocationService {
  late Position currentPosition; //assertion
  //constructor
  LocationService._internal();
  //instance of the class for location fetching
  static final LocationService _instance = LocationService._internal();
  //factory method designed for giving out the same instance.
  factory LocationService() {
    return _instance;
  }

  //validate permissions. If permissions are denied, ask, if still doesn't work, use the last known location.
  Future<void> determinePermissions() async {
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
          return;
        } else {
          return Future.error('Location permissions are denied');
        }
      }
    }//end of if statement blocks.

    // last thing we check because the user could have enabled permission beforehand
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, Unable to request permissions.');
    }

     await _instance.updateCurrentLocation();

  }//end of method


  //gets the current position at a given point in time.
  Future<void> updateCurrentLocation() async {
     currentPosition = await Geolocator.getCurrentPosition();
  }

  //next step is to create a function to consistently obtain the user's current location.



  //Future<void> determinePosition() async {
    //implementation for constant location fetching periodically.
  //}

  // Stream<Position> positionStream = Geolocator.getPositionStream();
  // positionStream.listen((Position position) {
  // print('New position: ${position.latitude}, ${position.longitude}');
  // });




  // Position? closestLocation(Position p1, Position p2, Position p3){
  //   //implementation for Sano regarding closest Campus.
  //   return currentPosition;
  // }

  void takePosition(Position p){
    this.currentPosition = p;
  }



} //end of class


