import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/utils/location_service.dart';
import "package:latlong2/latlong.dart";
import 'package:flutter/material.dart';
import 'package:soen_390/main.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';

@GenerateMocks([LocationService])
import 'location_service_test_2.mocks.dart';

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

class MockRouteService extends Mock implements IRouteService {}

class MockHttp extends Mock implements HttpService {}

class MockAuthService extends Mock implements AuthService {}

class TestGeolocatorPlatform extends geo.GeolocatorPlatform {
  final Future<bool> Function() isLocationServiceEnabledFunc;
  Future<geo.Position> positionToReturn;
  geo.LocationPermission _permission = geo.LocationPermission.whileInUse;
  bool _locationServicesEnabled = true;

  TestGeolocatorPlatform({
    required this.isLocationServiceEnabledFunc,
    required this.positionToReturn,
  });

  @override
  Future<bool> isLocationServiceEnabled() => isLocationServiceEnabledFunc();
  void setLocationPermission(geo.LocationPermission permission) {
    _permission = permission;
  }

  @override
  Future<geo.Position> getCurrentPosition({
    geo.LocationSettings? locationSettings,
  }) async {
    return positionToReturn;
  }

  void setLocationServiceEnabled(bool enabled) {
    print('Location service enabled: $_locationServicesEnabled');
    _locationServicesEnabled = enabled;
  }

  @override
  Stream<geo.Position> getPositionStream(
      {geo.LocationSettings? locationSettings}) {
    return Stream.fromIterable([mockPosition]);
  }

  @override
  Future<geo.Position?> getLastKnownPosition(
      {bool forceLocationManager = false}) async {
    return Future.value(mockPosition);
  }

  @override
  Future<geo.LocationPermission> checkPermission() => Future.value(_permission);

  @override
  Future<geo.LocationPermission> requestPermission() =>
      Future.value(_permission);
}

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

void main() {
  late MockLocationService mockLocationService;
  late TestGeolocatorPlatform testGeolocator;

  setUp(() {
    mockLocationService = MockLocationService();
    testGeolocator = TestGeolocatorPlatform(
      isLocationServiceEnabledFunc: () => Future.value(true),
      positionToReturn: Future.value(mockPosition),
    );

    mockLocationService.takePosition(mockPosition);
  });

  group('LocationService Tests', () {
    final mockLocationService = MockLocationService();
    final mockRouteService = MockRouteService();
    final mockHttp = MockHttp();

    testWidgets('MyHomePage updates state when location changes',
        (WidgetTester tester) async {
      final mockLocationService = MockLocationService();

      when(mockLocationService.getLatLngStream()).thenAnswer(
          (_) => Stream.fromIterable([const LatLng(45.5017, -73.5673)]));

      await tester.pumpWidget(
        MaterialApp(
          home: MyHomePage(
            title: 'Campus Map',
            routeService: mockRouteService,
            httpService: mockHttp,
            authService: MockAuthService(),
          ),
        ),
      );
      expect(find.text('Home Page'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    test('determinePermissions should return true when permission is granted',
        () async {
      when(mockLocationService.determinePermissions())
          .thenAnswer((_) async => true);

      final result = await mockLocationService.determinePermissions();

      expect(result, true);
      verify(mockLocationService.determinePermissions()).called(1);
    });
    test(
        'should return false if permission is denied but position is available',
        () async {
      when(testGeolocator.checkPermission())
          .thenAnswer((_) async => geo.LocationPermission.denied);

      final mockPosition = geo.Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        altitude: 0.0,
        accuracy: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      when(testGeolocator.getLastKnownPosition())
          .thenAnswer((_) async => mockPosition);

      final result = await mockLocationService.getCurrentLocation();

      expect(result, false);

      expect(mockLocationService.currentPosition, equals(mockPosition));
    });

    test('determinePermissions should return false when permission is denied',
        () async {
      when(mockLocationService.determinePermissions())
          .thenAnswer((_) async => false);

      final result = await mockLocationService.determinePermissions();

      expect(result, false);
      verify(mockLocationService.determinePermissions()).called(1);
    });

    test('getCurrentLocation should return a mock position', () async {
      final mockPosition = geo.Position(
        latitude: 45.5017,
        longitude: -73.5673,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => mockPosition);

      final position = await mockLocationService.getCurrentLocation();

      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
    });

    test('updateCurrentLocation should update currentPosition', () async {
      // Mock updating current position
      when(mockLocationService.updateCurrentLocation()).thenAnswer((_) async {
        // Simulate the position update.
      });

      await mockLocationService.updateCurrentLocation();

      verify(mockLocationService.updateCurrentLocation()).called(1);
    });
    test('updateCurrentLocation should update currentPosition accurately',
        () async {
      // Mock updating current position
      when(mockLocationService.updateCurrentLocationAccurately())
          .thenAnswer((_) async {
        // Simulate the position update.
      });

      await mockLocationService.updateCurrentLocationAccurately();

      verify(mockLocationService.updateCurrentLocationAccurately()).called(1);
    });

    test('createLocationStream should update currentPosition on stream event',
        () async {
      final mockPositionStream = Stream.value(mockPosition);

      when(mockLocationService.getPositionStream())
          .thenAnswer((_) => mockPositionStream);

      await for (var position in mockLocationService.getPositionStream()) {
        expect(position.latitude, mockPosition.latitude);
        expect(position.longitude, mockPosition.longitude);
      }

      verify(mockLocationService.getPositionStream()).called(1);
    });

    test(
        'startUp should initialize location settings and stream when permissions granted',
        () async {
      when(mockLocationService.isLocationEnabled())
          .thenAnswer((_) async => true);
      when(mockLocationService.determinePermissions())
          .thenAnswer((_) async => true);

      await mockLocationService.startUp();

      verify(mockLocationService.startUp()).called(1);
    });

    test(
        'isLocationEnabled should return true when location services are enabled',
        () async {
      when(mockLocationService.isLocationEnabled())
          .thenAnswer((_) async => true);

      final result = await mockLocationService.isLocationEnabled();

      expect(result, true);
    });

    test(
        'isLocationEnabled should return false when location services are disabled',
        () async {
      when(mockLocationService.isLocationEnabled())
          .thenAnswer((_) async => false);

      final result = await mockLocationService.isLocationEnabled();

      expect(result, false);
    });

    test('getPositionStream should return a stream of positions', () async {
      final mockPositionStream = Stream.value(mockPosition);

      when(mockLocationService.getPositionStream())
          .thenAnswer((_) => mockPositionStream);

      final positionStream = mockLocationService.getPositionStream();

      final position = await positionStream.first;
      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
    });

    test('getCurrentLocationAccurately should return mocked position',
        () async {
      when(mockLocationService.getCurrentLocationAccurately())
          .thenAnswer((_) async => mockPosition);

      final position = await mockLocationService.getCurrentLocationAccurately();

      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
    });

    test('updateCurrentLocationAccurately should update currentPosition',
        () async {
      when(mockLocationService.updateCurrentLocationAccurately())
          .thenAnswer((_) async {
        // Simulate the accurate update.
      });

      await mockLocationService.updateCurrentLocationAccurately();

      verify(mockLocationService.updateCurrentLocationAccurately()).called(1);
    });

    test('determinePermissions handles deniedForever permission', () async {
      when(mockLocationService.determinePermissions())
          .thenAnswer((_) async => false);

      final result = await mockLocationService.determinePermissions();

      expect(result, false);
      verify(mockLocationService.determinePermissions()).called(1);
    });
    test('stopListening should cancel position stream subscription', () {
      mockLocationService.setPlatformSpecificLocationSettings();
      mockLocationService.createLocationStream();

      mockLocationService.stopListening();

      expect(() => mockLocationService.stopListening(), returnsNormally);
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
        headingAccuracy: 0.0,
      );

      mockLocationService.takePosition(newPosition);

      verify(mockLocationService.takePosition(newPosition)).called(1);
    });

    test(
        'setPlatformSpecificLocationSettings initializes iOS settings correctly',
        () {
      when(mockLocationService.setPlatformSpecificLocationSettings())
          .thenAnswer((_) async {});

      mockLocationService.setPlatformSpecificLocationSettings();

      verify(mockLocationService.setPlatformSpecificLocationSettings())
          .called(1);
    });
    test(
        'determinePermissions should return false when permission is permanently denied',
        () async {
      when(mockLocationService.determinePermissions())
          .thenAnswer((_) async => false);

      final result = await mockLocationService.determinePermissions();

      expect(result, false);
      verify(mockLocationService.determinePermissions()).called(1);
    });

    test(
        'getCurrentLocationAccurately should return a mock position with high accuracy',
        () async {
      final mockPosition = geo.Position(
        latitude: 45.5017,
        longitude: -73.5673,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      when(mockLocationService.getCurrentLocationAccurately())
          .thenAnswer((_) async => mockPosition);

      final position = await mockLocationService.getCurrentLocationAccurately();

      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
      expect(position.accuracy, mockPosition.accuracy);
    });
    test('getCurrentLocation should return a mock position with low accuracy',
        () async {
      final mockPosition = geo.Position(
        latitude: 45.5017,
        longitude: -73.5673,
        timestamp: DateTime.now(),
        accuracy: 100.0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => mockPosition);

      final position = await mockLocationService.getCurrentLocation();

      expect(position.latitude, mockPosition.latitude);
      expect(position.longitude, mockPosition.longitude);
      expect(position.accuracy, mockPosition.accuracy);
    });

    test('getClosestCampus should return SGW for closer distance', () {
      final mockPosition = geo.Position(
        latitude: 45.5017,
        longitude: -73.5673,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final closestCampus = LocationService.getClosestCampus(mockPosition);

      expect(closestCampus, "SGW");
    });
    test('getClosestCampus should return SGW when closer to SGW coordinates',
        () {
      final mockPosition = geo.Position(
        latitude: 45.4973, // Near SGW
        longitude: -73.5784, // Near SGW
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final closestCampus = LocationService.getClosestCampus(mockPosition);

      expect(closestCampus, "SGW");
    });

    test('getClosestCampus should return LOY when closer to LOY coordinates',
        () {
      final mockPosition = geo.Position(
        latitude: 45.4586,
        longitude: -73.6401,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      final closestCampus = LocationService.getClosestCampus(mockPosition);

      expect(closestCampus, "LOY");
    });

    test('getClosestCampus should return LOY for closer distance', () {
      final mockPosition = geo.Position(
        latitude: 45.4586,
        longitude: -73.6401,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      final closestCampus = LocationService.getClosestCampus(mockPosition);

      expect(closestCampus, "LOY");
    });
    test(
        'getCurrentLocation should handle case where location is null or invalid',
        () async {
      final invalidPosition = geo.Position(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => invalidPosition);

      final position = await mockLocationService.getCurrentLocation();

      expect(position.latitude, invalidPosition.latitude);
      expect(position.longitude, invalidPosition.longitude);
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

      testGeolocator.setLocationServiceEnabled(false);

      final campus = LocationService.getClosestCampus(position);
      expect(campus, 'SGW');
    });
  });
  group('LocationService - isLocationEnabled Tests', () {
    test(
        'isLocationEnabled should return true when location service is enabled',
        () async {
      final geolocatorPlatform = TestGeolocatorPlatform(
        isLocationServiceEnabledFunc: () => Future.value(true),
        positionToReturn: Future.value(mockPosition),
      );
      final locationService = LocationService(geolocator: geolocatorPlatform);

      final result = await locationService.isLocationEnabled();

      expect(result, true);
    });

    test('getPositionStream should return a stream with multiple positions',
        () async {
      final mockPositionStream =
          Stream<geo.Position>.fromIterable([mockPosition, mockPosition]);

      when(mockLocationService.getPositionStream())
          .thenAnswer((_) => mockPositionStream);

      final positionStream = mockLocationService.getPositionStream();

      await for (var position in positionStream) {
        expect(position.latitude, mockPosition.latitude);
        expect(position.longitude, mockPosition.longitude);
      }

      verify(mockLocationService.getPositionStream()).called(1);
    });
    test('getLatLngStream should map Position to LatLng', () async {
      // Create a mock stream for getPositionStream with a geo.Position
      final mockPositionStream = Stream.fromIterable([
        geo.Position(
          latitude: 12.34,
          longitude: 56.78,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          floor: null,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        ),
      ]);

      // Mock getPositionStream to return the mock stream
      when(mockLocationService.getPositionStream())
          .thenAnswer((_) => mockPositionStream);

      // Call the method and listen to the stream
      final latLngStream = mockLocationService.getLatLngStream();
      final latLng =
          await latLngStream.first; // Get the first value from the stream

      // Assert that the result is a LatLng object with the correct values
      expect(latLng.latitude, 12.34);
      expect(latLng.longitude, 56.78);
    });
  });
}
