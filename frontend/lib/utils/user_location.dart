import 'package:geolocator/geolocator.dart';

//THIS USES THE GEOLOCATOR FLUTTER PACKAGES. We have moved to flutter_background_geolocation package
//refer to the user_location_util.dart file in this folder for the location functionalities.

//function for current location
//this is the "state"



class LocationService {
  late Position currentPosition; //assertion
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

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
        } else {
          return Future.error('Location permissions are denied');
        }
      }
    }

    // last thing we check because the user could have enabled permission beforehand
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, Unable to request permissions.');
    }


  }//end of method

  Future<void> determinePosition() async {
    //implementation for constant location fetching periodically.
  }

  Stream<Position> positionStream = Geolocator.getPositionStream();
  positionStream.listen((Position position) {
  print('New position: ${position.latitude}, ${position.longitude}');
  });




  Position? closestLocation(Position p1, Position p2, Position p3){
    //implementation for Sano regarding closest Campus.
    return currentPosition;
  }

  void takePosition(Position p){
    this.currentPosition = p;
  }



} //end of class


