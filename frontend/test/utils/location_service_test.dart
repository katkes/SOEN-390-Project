import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride, TargetPlatform;

/// Helper function to create a mock [geo.Position] object.
///
/// Returns a [geo.Position] with predefined values for testing purposes.
geo.Position get mockPosition => geo.Position(
      latitude: 45.5017,
      longitude: -73.5673,
      timestamp: DateTime.now(),
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      accuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

/// Mock implementation of [geo.GeolocatorPlatform] for testing.
///
/// This class overrides methods from [geo.GeolocatorPlatform] to provide
/// controlled behavior for testing the [LocationService] class.
class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements geo.GeolocatorPlatform {
  geo.LocationPermission _permission = geo.LocationPermission.whileInUse;
  bool _locationServicesEnabled = true;

  /// Sets the mock location permission for testing.
  void setLocationPermission(geo.LocationPermission permission) {
    _permission = permission;
  }

  /// Sets whether location services are enabled for testing.
  void setLocationServiceEnabled(bool enabled) {
    _locationServicesEnabled = enabled;
  }

  @override
  Future<geo.LocationPermission> checkPermission() => Future.value(_permission);

  @override
  Future<geo.LocationPermission> requestPermission() =>
      Future.value(_permission);

  @override
  Future<bool> isLocationServiceEnabled() =>
      Future.value(_locationServicesEnabled);

  @override
  Future<geo.Position?> getLastKnownPosition(
      {bool forceLocationManager = false}) async {
    return Future.value(mockPosition);
  }

  @override
  Future<geo.Position> getCurrentPosition(
          {geo.LocationSettings? locationSettings}) =>
      Future.value(mockPosition);

  @override
  Stream<geo.Position> getPositionStream(
      {geo.LocationSettings? locationSettings}) {
    return Stream.fromIterable([mockPosition]);
  }

  @override
  Future<bool> openAppSettings() => Future.value(true);

  @override
  Future<bool> openLocationSettings() => Future.value(true);
}

void main() {
  late MockGeolocatorPlatform mockGeolocatorPlatform;
  late LocationService locationService;

  /// Sets up the test environment before each test.
  ///
  /// Initializes the [MockGeolocatorPlatform] and injects it into the
  /// [LocationService] instance. Also ensures that `currentPosition` is initialized.
  setUp(() {
    // Reset any static state to prevent test interference
    LocationService.resetInstance();

    mockGeolocatorPlatform = MockGeolocatorPlatform();
    locationService = LocationService(
        geolocator: mockGeolocatorPlatform); // Inject mock dependency

    // Ensure `currentPosition` is initialized
    locationService.takePosition(mockPosition);
  });

  group('LocationService Tests', () {
    test('determinePermissions should return true when permission is granted',
        () async {
      mockGeolocatorPlatform.setLocationServiceEnabled(true);
      mockGeolocatorPlatform
          .setLocationPermission(geo.LocationPermission.whileInUse);

      bool result = await locationService.determinePermissions();

      expect(result, true);
      expect(locationService.serviceEnabled, true);
      expect(locationService.permission, geo.LocationPermission.whileInUse);
    });

    test('determinePermissions should return false when permission is denied',
        () async {
      // Set up the mocks
      mockGeolocatorPlatform.setLocationServiceEnabled(true);
      mockGeolocatorPlatform
          .setLocationPermission(geo.LocationPermission.denied);

      // Execute the test
      bool result = await locationService.determinePermissions();

      // Verify the result
      expect(result, false);
    });

    test('getCurrentLocation should return mocked position', () async {
      // Act
      final position = await locationService.getCurrentLocation();

      // Assert
      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
    });

    test('updateCurrentLocation should update currentPosition', () async {
      // Act
      await locationService.updateCurrentLocation();

      // Assert
      expect(locationService.currentPosition.latitude, mockPosition.latitude);
      expect(locationService.currentPosition.longitude, mockPosition.longitude);
    });

    test('createLocationStream should update currentPosition on stream event',
        () async {
      // Arrange
      locationService.takePosition(mockPosition);
      locationService.setPlatformSpecificLocationSettings();

      // Act
      locationService.createLocationStream();

      // Allow time for stream events to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(locationService.currentPosition.latitude, mockPosition.latitude);
      expect(locationService.currentPosition.longitude, mockPosition.longitude);
    });

    test('startUp should throw exception when location services are disabled',
        () async {
      // Arrange
      mockGeolocatorPlatform.setLocationServiceEnabled(false);

      // Act & Assert - Use expectLater with async function execution
      await expectLater(locationService.startUp,
          throwsA(isA<PermissionNotEnabledException>()));
    });

    test(
        'startUp should initialize location settings and stream when permissions granted',
        () async {
      // Arrange
      mockGeolocatorPlatform.setLocationServiceEnabled(true);
      mockGeolocatorPlatform
          .setLocationPermission(geo.LocationPermission.whileInUse);

      // Act
      await locationService.startUp(); // Ensure async execution finishes

      // Assert
      expect(locationService.serviceEnabled, true);
      expect(locationService.permission, geo.LocationPermission.whileInUse);

      // Ensure locSetting is properly initialized
      expect(() => locationService.locSetting, isNot(throwsA(anything)));
    });

    test(
        'isLocationEnabled should return true when location services are enabled',
        () async {
      // Arrange
      mockGeolocatorPlatform.setLocationServiceEnabled(true);

      // Act
      bool result = await locationService.isLocationEnabled();

      // Assert
      expect(result, true);
    });

    test(
        'isLocationEnabled should return false when location services are disabled',
        () async {
      // Arrange
      mockGeolocatorPlatform.setLocationServiceEnabled(false);

      // Act
      bool result = await locationService.isLocationEnabled();

      // Assert
      expect(result, false);
    });

    test('getPositionStream should return a stream of positions', () async {
      // Arrange
      locationService.setPlatformSpecificLocationSettings();

      // Act
      final positionStream = locationService.getPositionStream();

      // Assert
      final position = await positionStream.first;
      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
    });

    test(
        'getPositionStream should initialize location settings if not initialized',
        () async {
      // Arrange
      locationService = LocationService(geolocator: mockGeolocatorPlatform);

      // Act
      final positionStream = locationService.getPositionStream();

      // Assert
      final position = await positionStream.first;
      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
      expect(locationService.locSetting.accuracy, geo.LocationAccuracy.high);
      expect(locationService.locSetting.distanceFilter, 4);
    });

    test('getCurrentLocationAccurately should return mocked position',
        () async {
      final position = await locationService.getCurrentLocationAccurately();

      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
    });

    test('updateCurrentLocationAccurately should update currentPosition',
        () async {
      await locationService.updateCurrentLocationAccurately();

      expect(locationService.currentPosition.latitude, mockPosition.latitude);
      expect(locationService.currentPosition.longitude, mockPosition.longitude);
    });

    test('stopListening should cancel position stream subscription', () {
      locationService.setPlatformSpecificLocationSettings();
      locationService.createLocationStream();

      locationService.stopListening();

      // No direct way to check if stream is cancelled, but we can verify no errors occur
      expect(() => locationService.stopListening(), returnsNormally);
    });

    test('determinePermissions handles deniedForever permission', () async {
      mockGeolocatorPlatform.setLocationServiceEnabled(true);
      mockGeolocatorPlatform
          .setLocationPermission(geo.LocationPermission.deniedForever);

      bool result = await locationService.determinePermissions();

      expect(result, false);
      expect(locationService.permission, geo.LocationPermission.deniedForever);
    });

    test('takePosition correctly updates currentPosition', () {
      final newPosition = geo.Position(
          latitude: 40.7128,
          longitude: -74.0060,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0);

      locationService.takePosition(newPosition);

      expect(locationService.currentPosition.latitude, 40.7128);
      expect(locationService.currentPosition.longitude, -74.0060);
    });

    test('setPlatformSpecificLocationSettings should initialize only once', () {
      locationService.setPlatformSpecificLocationSettings();
      final initialSettings = locationService.locSetting;

      // Call again to verify it doesn't change
      locationService.setPlatformSpecificLocationSettings();

      expect(locationService.locSetting, equals(initialSettings));
    });

    test(
        'setPlatformSpecificLocationSettings initializes iOS settings correctly',
        () {
      // Arrange
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      locationService = LocationService(geolocator: mockGeolocatorPlatform);

      // Act
      locationService.setPlatformSpecificLocationSettings();

      // Assert
      expect(locationService.locSetting.accuracy, geo.LocationAccuracy.high);
      expect(locationService.locSetting.distanceFilter, 4);

      // Cleanup
      debugDefaultTargetPlatformOverride = null;
    });

    test(
        'setPlatformSpecificLocationSettings initializes other platform settings correctly',
        () {
      // Arrange
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      locationService = LocationService(geolocator: mockGeolocatorPlatform);

      // Act
      locationService.setPlatformSpecificLocationSettings();

      // Assert
      expect(locationService.locSetting.accuracy, geo.LocationAccuracy.high);
      expect(locationService.locSetting.distanceFilter, 4);

      // Cleanup
      debugDefaultTargetPlatformOverride = null;
    });

    // Tests for getClosestCampus method
    group('getClosestCampus Tests', () {
      test('returns SGW when near SGW', () {
        final position = geo.Position(
          // Coordinates for the Bell Centre
          latitude: 45.495590,
          longitude: -73.568657,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          floor: null,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        final campus = LocationService.getClosestCampus(position);
        expect(campus, 'SGW');
      });

      test('returns Loyola when near Loyola', () {
        final position = geo.Position(
          // Coordinates for Rene-Lévesque Park
          latitude: 45.428664,
          longitude: -73.672164,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          floor: null,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        final campus = LocationService.getClosestCampus(position);
        expect(campus, 'LOY');
      });

      test('returns SGW when equidistant from both', () {
        final position = geo.Position(
          latitude: 45.4586,
          longitude: -73.5167,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          floor: null,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        final campus = LocationService.getClosestCampus(position);
        expect(campus, 'SGW');
      });

      test('returns SGW when permission is denied', () {
        final position = geo.Position(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          floor: null,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        mockGeolocatorPlatform
            .setLocationPermission(geo.LocationPermission.denied);

        final campus = LocationService.getClosestCampus(position);
        expect(campus, 'SGW');
      });

      test('returns SGW when location is unavailable', () {
        final position = geo.Position(
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          floor: null,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );

        mockGeolocatorPlatform.setLocationServiceEnabled(false);

        final campus = LocationService.getClosestCampus(position);
        expect(campus, 'SGW');
      });
    });

    group('checkIfPositionIsAtSGW Tests', () {
      test('returns true when position is within 2km of SGW campus', () {
        // Using the exact SGW coordinates: 45.4973, -73.5784
        final position = geo.Position(
          latitude: 45.4973,
          longitude: -73.5784,
          timestamp: DateTime.now(),
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          accuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        expect(LocationService.checkIfPositionIsAtSGW(position), isTrue);
      });

      test('returns false when position is more than 2km away from SGW campus',
          () {
        // Coordinates far from SGW campus
        final position = geo.Position(
          latitude: 45.4500,
          longitude: -73.7000,
          timestamp: DateTime.now(),
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          accuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        expect(LocationService.checkIfPositionIsAtSGW(position), isFalse);
      });
    });

    group('checkIfPositionIsAtLOY Tests', () {
      test('returns true when position is within 2km of LOY campus', () {
        // Using the exact LOY coordinates: 45.4586, -73.6401
        final position = geo.Position(
          latitude: 45.4586,
          longitude: -73.6401,
          timestamp: DateTime.now(),
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          accuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        expect(LocationService.checkIfPositionIsAtLOY(position), isTrue);
      });

      test('returns false when position is more than 2km away from LOY campus',
          () {
        // Coordinates far from LOY campus
        final position = geo.Position(
          latitude: 45.5000,
          longitude: -73.5500,
          timestamp: DateTime.now(),
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          accuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        expect(LocationService.checkIfPositionIsAtLOY(position), isFalse);
      });
    });
  });
}
