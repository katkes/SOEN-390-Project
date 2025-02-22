//This file is for testing the user location service from user_location_util.dart found inside the utils folder

import '../lib/utils/user_location_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

// Create a mock class for BackgroundGeolocation
class MockBackgroundGeolocation extends Mock implements bg.BackgroundGeolocation {}


void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  group('Singleton Pattern location service Test', () {
    test('LocationService should always return the same instance cuz its a singleton', () {
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

      // Mock the response for getting the current location
      var mockLocation = bg.Location.coords(
          latitude: 37.7749,
          longitude: -122.4194,
          time: DateTime.now().millisecondsSinceEpoch,
          speed: 0.0,
          altitude: 0.0,
          accuracy: 5.0,
          heading: 0.0,
          velocity: 0.0,
          isMock: false
      );

      // Mock the method to return the mock location
      when(mockBackgroundGeolocation.getCurrentPosition()).thenAnswer((_) async => mockLocation);

      // Simulate the behavior of getUserLocation
      await instance.getUserLocation();

      // Check that the location was set
      expect(instance.currentLocation, isNotNull);
      expect(instance.currentLocation?.latitude, 37.7749);
      expect(instance.currentLocation?.longitude, -122.4194);
    });

  });
}
