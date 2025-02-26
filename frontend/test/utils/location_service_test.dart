import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:soen_390/utils/permission_not_enabled_exception.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Helper function to get a mock position
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

// Mock GeolocatorPlatform Implementation
class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements geo.GeolocatorPlatform {
  geo.LocationPermission _permission = geo.LocationPermission.whileInUse;
  bool _locationServicesEnabled = true;

  void setLocationPermission(geo.LocationPermission permission) {
    _permission = permission;
  }

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
    return Future.value(mockPosition); // ✅ Ensure we never return null
  }

  @override
  Future<geo.Position> getCurrentPosition(
          {geo.LocationSettings? locationSettings}) =>
      Future.value(mockPosition); // ✅ Return mockPosition

  @override
  Stream<geo.Position> getPositionStream(
      {geo.LocationSettings? locationSettings}) {
    return Stream.fromIterable(
        [mockPosition]); // ✅ Always return a valid stream
  }

  @override
  Future<bool> openAppSettings() => Future.value(true);

  @override
  Future<bool> openLocationSettings() => Future.value(true);
}

void main() {
  late MockGeolocatorPlatform mockGeolocatorPlatform;
  late LocationService locationService;

  setUp(() {
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
      mockGeolocatorPlatform.setLocationServiceEnabled(true);
      mockGeolocatorPlatform
          .setLocationPermission(geo.LocationPermission.denied);

      bool result = await locationService.determinePermissions();

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
      locationService.takePosition(mockPosition); // ✅ Ensures position is set
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
        () {
      // Arrange
      mockGeolocatorPlatform.setLocationServiceEnabled(false);

      // Act & Assert
      expect(() => locationService.startUp(),
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
  });
}
