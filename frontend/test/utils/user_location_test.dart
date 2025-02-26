import 'package:soen_390/utils/user_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
import 'dart:async';


// run dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([GeolocatorPlatform])
import 'user_location_test.mocks.dart';

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
}// end of mock position class

    // locSetting

    // possible values
    // serviceEnabled = true
    // serviceEnabled = false
    // permission = LocationPermission.denied
    // permission = LocationPermission.deniedForever
    // permission = LocationPermission.always

    // flow
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



void main() {
  late MockGeolocatorPlatform mockGeolocatorPlatform;
  late LocationService locationService;

  setUp(() {
    mockGeolocatorPlatform = MockGeolocatorPlatform();
    // GeolocatorPlatform.instance = mockGeolocatorPlatform;
    locationService = LocationService();
  });

  group('determinePermissions tests', () {
    // Flow 1.1: serviceEnabled = false, permission = LocationPermission.always
    test('should return false when location services are disabled', () async {
      // Arrange
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);

      // Act
      final result = await locationService.determinePermissions();

      // Assert
      expect(result, false);
      expect(locationService.serviceEnabled, false);
      expect(locationService.permission, LocationPermission.always);
    });

    // Flow 1.2: serviceEnabled = true, permission = LocationPermission.denied -> still denied after request
    test('should return false when permission is denied and stays denied after request', () async {
      // Arrange
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocatorPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocatorPlatform.getLastKnownPosition())
          .thenAnswer((_) async => null);

      // Act
      final result = await locationService.determinePermissions();

      // Assert
      expect(result, false);
      expect(locationService.serviceEnabled, true);
      expect(locationService.permission, LocationPermission.denied);
    });

    // Flow 1.2 variation: service enabled, permission denied, but there's a last known position
    test('should return false when permission is denied but last known position is available', () async {
      // Arrange
      final mockPosition = Position(
        latitude: 45.4973,
        longitude: -73.5790,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
        altitude: 0,
        heading: 0,

        speed: 0,
        speedAccuracy: 0,
      );

      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocatorPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocatorPlatform.getLastKnownPosition())
          .thenAnswer((_) async => mockPosition);

      // Act
      final result = await locationService.determinePermissions();

      // Assert
      expect(result, false);
      expect(locationService.serviceEnabled, true);
      expect(locationService.permission, LocationPermission.denied);
      expect(locationService.currentPosition, mockPosition);
    });

    // Flow 1.3: serviceEnabled = true, permission = LocationPermission.deniedForever
    test('should return false when permission is permanently denied', () async {
      // Arrange
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.deniedForever);

      // Act
      final result = await locationService.determinePermissions();

      // Assert
      expect(result, false);
      expect(locationService.serviceEnabled, true);
      expect(locationService.permission, LocationPermission.deniedForever);
    });

    // Flow 1.4: serviceEnabled = true, permission = LocationPermission.always
    test('should return true when location services and permissions are enabled', () async {
      // Arrange
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);

      // Act
      final result = await locationService.determinePermissions();

      // Assert
      expect(result, true);
      expect(locationService.serviceEnabled, true);
      expect(locationService.permission, LocationPermission.always);
    });

    // Flow variation: initially denied but then granted after request
    test('should return true when permission is initially denied but then granted', () async {
      // Arrange
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(mockGeolocatorPlatform.requestPermission())
          .thenAnswer((_) async => LocationPermission.always);

      // Act
      final result = await locationService.determinePermissions();

      // Assert
      expect(result, true);
      expect(locationService.serviceEnabled, true);
      expect(locationService.permission, LocationPermission.always);
    });
  });

  group('getCurrentLocation and updateCurrentLocation tests', () {
    test('getCurrentLocation should call Geolocator.getCurrentPosition with proper params', () async {
      // Arrange
      final mockPosition = Position(
        latitude: 45.4973,
        longitude: -73.5790,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );

      when(mockGeolocatorPlatform.getCurrentPosition(
        locationSettings: anyNamed('locationSettings'),
      )).thenAnswer((_) async => mockPosition);

      // Act
      final result = await locationService.getCurrentLocation();

      // Assert
      expect(result, mockPosition);
      verify(mockGeolocatorPlatform.getCurrentPosition(
        locationSettings: argThat(
            predicate<LocationSettings>((settings) =>
            settings.accuracy == LocationAccuracy.low),
            named: 'locationSettings'
        ),
      )).called(1);
    });

    test('updateCurrentLocation should update currentPosition property', () async {
      // Arrange
      final mockPosition = Position(
        latitude: 45.4973,
        longitude: -73.5790,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );

      when(mockGeolocatorPlatform.getCurrentPosition(
        locationSettings: anyNamed('locationSettings'),
      )).thenAnswer((_) async => mockPosition);

      // Act
      await locationService.updateCurrentLocation();

      // Assert
      expect(locationService.currentPosition, mockPosition);
    });
  });

  group('location stream tests', () {
    test('createLocationStream should listen to position updates', () async {
      // Arrange
      final controller = StreamController<Position>();
      final mockPosition = Position(
        latitude: 45.4973,
        longitude: -73.5790,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );

      when(mockGeolocatorPlatform.getPositionStream(
        locationSettings: anyNamed('locationSettings'),
      )).thenAnswer((_) => controller.stream);

      // Act
      locationService.setPlatformSpecificLocationSettings();
      locationService.createLocationStream();

      // Add a position update
      controller.add(mockPosition);
      await Future.delayed(Duration.zero); // Let the event loop process the stream event

      // Assert
      expect(locationService.currentPosition, mockPosition);

      // Clean up
      await controller.close();
      locationService.stopListening();
    });
  });

  group('startUp tests', () {
    test('startUp should throw PermissionNotEnabledException when permissions are not granted', () async {
      // Arrange
      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      // Act & Assert
      expect(() async => locationService.startUp(), throwsA(isA<PermissionNotEnabledException>()));
    });

    test('startUp should set up location stream when permissions are granted', () async {
      // Arrange
      final controller = StreamController<Position>();

      when(mockGeolocatorPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(mockGeolocatorPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);
      when(mockGeolocatorPlatform.getPositionStream(
        locationSettings: anyNamed('locationSettings'),
      )).thenAnswer((_) => controller.stream);

      // Act
      locationService.startUp();

      // Clean up
      await controller.close();
      locationService.stopListening();

      // No direct assertions, but verify methods were called
      verify(mockGeolocatorPlatform.getPositionStream(
        locationSettings: anyNamed('locationSettings'),
      )).called(1);
    });
  });
}
