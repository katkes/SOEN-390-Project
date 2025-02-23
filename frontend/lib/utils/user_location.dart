import 'package:geolocator/geolocator.dart';

//THIS USES THE GEOLOCATOR FLUTTER PACKAGES. We have moved to flutter_background_geolocation package
//refer to the user_location_util.dart file in this folder for the location functionalities.

//function for current location
//this is the "state"

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  //check if the device even has a location feature thing (most will, so im not really worried)
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  //check if the permission is denied.
  permission = await Geolocator.checkPermission();
  //if location is never allowed, then we dont want to show another err message like so;
  //im not sure how this will look in the app, and i also dont think this will ask the user if they want to enable location
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, Unable to request permissions.');
  }

  //if the location is denied, ask for it. If it is denied again, try using the last known location. Otherwise, just send an error
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      //if its denied again
      //use the latest known position (better than anything ig?)
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return position;
      } else {
        return Future.error('Location permissions are denied');
      }
    }
  }

  return await Geolocator.getCurrentPosition();
  //whenever you catch this from a function call, it must be an identifier of type like
  // Position position. Otherwise, use type inference like var position = ...
  // but i recommend to use Position position since it tells you exactly what the pointer is
}
