//This file is for testing the user location service from user_location_util.dart found inside the utils folder

import 'package:flutter/material.dart';
import '../lib/utils/user_location_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Singleton Pattern Test', () {
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
  });
}



