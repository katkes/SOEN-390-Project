//This file is for testing the user location service from user_location_util.dart found inside the utils folder

import 'package:soen_390/utils/user_location_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

// Create a mock class for BackgroundGeolocation
class MockBackgroundGeolocation extends Mock implements bg.BackgroundGeolocation {
  Future<bg.Location> getCurrentPosition() async {
    return bg.Location({
      'coords': {
        'latitude': 37.7749,
        'longitude': -122.4194,
        'accuracy': 5.0,
        'altitude': 0.0,
        'ellipsoidal_altitude': 0.0,
        'heading': 0.0,
        'heading_accuracy': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'altitude_accuracy': 0.0,
      },
      'battery': {
        'is_charging': false,
        'level': 1.0,
      },
      'activity': {
        'type': 'still',
        'confidence': 100,
      },
      'timestamp': DateTime.now().toIso8601String(),
      'age': 0,
      'is_moving': false,
      'uuid': 'uuid',
      'odometer': 0.0,
      'sample': false,
      'event': '',
      'mock': false,
      'extras': null,
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Singleton Pattern location service Test', () {
    test(
        'LocationService should always return the same instance cuz its a singleton',
        () {
      // Create multiple instances
      var instance1 = LocationService();
      var instance2 = LocationService();
      var instance3 = LocationService();

      // All instances should point to the same object
      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
      expect(instance1, same(instance3));
    });

    test("CurrentLocation should return the current location", () async {
      var mockBackgroundGeolocation = MockBackgroundGeolocation();
      var instance = LocationService();
      await instance.startListeningForLocation();

      var mockLocation = await mockBackgroundGeolocation.getCurrentPosition(); //this is my data. I want to pass this Location object to my class

      instance.takeLocation(mockLocation);

      expect(instance.currentLocation, isNotNull);
      expect(instance.currentLocation.coords.latitude, 37.7749);
      expect(instance.currentLocation.coords.longitude, -122.4194);
    });
  });
}

//main test file
