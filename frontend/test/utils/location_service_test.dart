import 'package:soen_390/utils/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
import 'dart:async';

// run dart run build_runner build --delete-conflicting-outputs
import 'location_service_test.mocks.dart';

@GenerateMocks([GeolocatorPlatform])
void main() {
  late MockGeolocatorPlatform mockGeolocator;
  late LocationService locationService;

  setUp(() {
    mockGeolocator = MockGeolocatorPlatform();
    locationService = LocationService();
  });

  group('determinePermissions', () {
    test('should return false if location services are disabled', () async {
      when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => false);

      expect(await locationService.determinePermissions(), false);
    });

    test('should request permission if denied and return true if granted', () async {
      when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocator.requestPermission()).thenAnswer((_) async => LocationPermission.whileInUse);

      expect(await locationService.determinePermissions(), true);
    });
  });

  group('getCurrentLocation', () {
    test('should return a position when fetching location', () async {
      final mockPosition = Position(
        latitude: 45.0,
        longitude: -73.0,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
          altitudeAccuracy: 1.0,
          headingAccuracy: 1.0
      );

      when(mockGeolocator.getCurrentPosition(desiredAccuracy: anyNamed('desiredAccuracy')))
          .thenAnswer((_) async => mockPosition);

      final position = await locationService.getCurrentLocation();

      expect(position.latitude, 45.0);
      expect(position.longitude, -73.0);
    });
  });

  group('startUp', () {
    test('should throw PermissionNotEnabledException if permissions are not granted', () async {
      when(mockGeolocator.isLocationServiceEnabled()).thenAnswer((_) async => true);
      when(mockGeolocator.checkPermission()).thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocator.requestPermission()).thenAnswer((_) async => LocationPermission.denied);

      expect(() => locationService.startUp(), throwsA(isA<PermissionNotEnabledException>()));
    });
  });
}
