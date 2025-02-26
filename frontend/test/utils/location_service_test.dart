// location service specific imports
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
// flutter testing specific imports
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
// geolocator functionality specific imports
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';


// run "dart run build_runner build --delete-conflicting-outputs" to generate the mockups.
class MockGeolocatorPlatform extends Mock implements GeolocatorPlatform {}

// this class is used to test setPlatformSpecificLocationSettings() method.
// defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS
// defaultTargetPlatform == TargetPlatform.android
// defaultTargetPlatform // a random one that isnt IOS or Anndroid.
class MockOSSettings extends Mock implements Geolocator{
  Future<AndroidSettings> generateAndroidLocationSettings() async{
    return await AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4,
        forceLocationManager:true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:"Concordia navigation app will continue to receive your location even when you aren't using it",
          notificationTitle: "Running in Background",
          enableWakeLock: true,
        ));
  }
    Future<AppleSettings> generateiOSLocationSettings() async {
      return await AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 4,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    }
    Future<LocationSettings> generateDefaultLocationSettings() async {
      return await LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 4,
      );
    }
  }//end of MockSettings class

//flow of permission testing class
// 1.1
// serviceEnabled = false
// permission = LocationPermission.always
// should return false

// 1.2
// serviceEnabled = true
// permission = LocationPermission.denied
// should return false

//1.3
// serviceEnabled = true
// permission = LocationPermission.deniedForever
// should return false

//1.4
// serviceEnabled = true
// permission = permission = LocationPermission.always
// should return true


@GenerateMocks([GeolocatorPlatform])
void main() {

}
