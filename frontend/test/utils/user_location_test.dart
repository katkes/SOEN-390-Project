import 'package:soen_390/utils/user_location.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';

class MockPosition extends Mock implements Position {
  Future<Position> getCurrentPosition1() async {
    return Position(
      longitude: -122.084,
      latitude: 37.4219983,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 30.5,
      altitudeAccuracy: 5.0,
      heading: 270.0,
      headingAccuracy: 1.0,
      speed: 2.5,
      speedAccuracy: 0.5,
      floor: 3, // Optional
      isMocked: true, // Optional
    );
  }

  Future<Position> getCurrentPosition2() async {
    return Position(
      longitude: 137.287337,
      latitude: 57.932167,
      timestamp: DateTime.now(),
      accuracy: 7.0,
      altitude: 30.5,
      altitudeAccuracy: 2.0,
      heading: 270.0,
      headingAccuracy: 1.2,
      speed: 2.5,
      speedAccuracy: 0.5,
      floor: 5, // Optional
      isMocked: true, // Optional
    );
  }
}

void main() {

  group('Singleton Pattern location service Test', () {
    test(
        'LocationService should always return the same instance cuz its a singleton',
        () {
      var instance1 = LocationService();
      var instance2 = LocationService();
      var instance3 = LocationService();

      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
      expect(instance1, same(instance3));
    }); //end of first test

    test("Testing taking a position", () async {
      var instance = LocationService();
      final mockInstace = MockPosition();
      Position mockPosition = await mockInstace.getCurrentPosition1();
      instance.takePosition(mockPosition);

      expect(instance.currentPosition.latitude, equals(37.4219983));
      expect(instance.currentPosition.longitude, equals(-122.084));
    }); //end of second test

    // locSetting
    // serviceEnabled
    // permission


  }); //end of group
} //end of main method.
