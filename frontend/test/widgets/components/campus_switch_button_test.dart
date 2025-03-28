library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:soen_390/widgets/campus_switch_button.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:soen_390/utils/location_service.dart';

// Mock class for the GeolocatorPlatform interface.
class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  final geolocator.Position _mockPosition = geolocator.Position(
    latitude: 45.4979,
    longitude: -73.5796,
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

  @override
  Future<geolocator.LocationPermission> checkPermission() {
    return super.noSuchMethod(Invocation.method(#checkPermission, []),
        returnValue: Future.value(geolocator.LocationPermission.denied));
  }

  @override
  Future<geolocator.LocationPermission> requestPermission() {
    return super.noSuchMethod(Invocation.method(#requestPermission, []),
        returnValue: Future.value(geolocator.LocationPermission.whileInUse));
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return super.noSuchMethod(Invocation.method(#isLocationServiceEnabled, []),
        returnValue: Future.value(true));
  }

  @override
  Future<geolocator.Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) {
    return super.noSuchMethod(
        Invocation.method(
            #getCurrentPosition, [], {#locationSettings: locationSettings}),
        returnValue: Future.value(_mockPosition));
  }

  @override
  Future<geolocator.Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) {
    return super.noSuchMethod(
        Invocation.method(#getLastKnownPosition, [],
            {#forceLocationManager: forceLocationManager}),
        returnValue: Future.value(_mockPosition));
  }

  @override
  Stream<geolocator.Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return super.noSuchMethod(
        Invocation.method(
            #getPositionStream, [], {#locationSettings: locationSettings}),
        returnValue: Stream.value(_mockPosition));
  }

  @override
  double distanceBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return super.noSuchMethod(
        Invocation.method(#distanceBetween,
            [startLatitude, startLongitude, endLatitude, endLongitude]),
        returnValue: 10000.0);
  }
}

// Reset the LocationService singleton between tests.
void resetLocationServiceSingleton() {
  LocationService.resetInstance();
}

void main() {
  setUp(() {
    // Reset the singleton before each test.
    resetLocationServiceSingleton();
  });

  group('CampusSwitch Widget Tests', () {
    testWidgets('displays initial selection correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CampusSwitch(
            onSelectionChanged: (_) {},
            onLocationChanged: (_) {},
            selectedCampus: 'SGW',
          ),
        ),
      );

      expect(find.text('SGW'), findsOneWidget);
      expect(find.text('Loyola'), findsOneWidget);
    });

    testWidgets('switching campus updates selection and triggers callbacks',
        (WidgetTester tester) async {
      String? selectedCampus;
      LatLng? selectedLocation;

      await tester.pumpWidget(
        MaterialApp(
          home: CampusSwitch(
            onSelectionChanged: (campus) => selectedCampus = campus,
            onLocationChanged: (location) => selectedLocation = location,
            selectedCampus: 'SGW',
          ),
        ),
      );

      await tester.tap(find.text('Loyola'));
      await tester.pumpAndSettle();
      expect(selectedCampus, 'Loyola');
      expect(selectedLocation, const LatLng(45.4581, -73.6391));

      await tester.tap(find.text('SGW'));
      await tester.pumpAndSettle();
      expect(selectedCampus, 'SGW');
      expect(selectedLocation, const LatLng(45.497856, -73.579588));
    });

    group('initClosestCampus() permission & location scenarios', () {
      testWidgets('requests permission if initially denied and then granted',
          (WidgetTester tester) async {
        final mockGeolocator = MockGeolocatorPlatform();

        // Override specific behaviors for this test.
        when(mockGeolocator.checkPermission()).thenAnswer(
            (_) => Future.value(geolocator.LocationPermission.denied));
        when(mockGeolocator.requestPermission()).thenAnswer(
            (_) => Future.value(geolocator.LocationPermission.whileInUse));
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) => Future.value(true));

        // Install the mock.
        GeolocatorPlatform.instance = mockGeolocator;

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              selectedCampus: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        // In this test, the new campus remains 'SGW' because the computed closest campus
        // from the mocked position is SGW.
        expect(state.selectedCampus, 'SGW');
      });

      testWidgets('handles permission denied permanently',
          (WidgetTester tester) async {
        final mockGeolocator = MockGeolocatorPlatform();

        when(mockGeolocator.checkPermission()).thenAnswer(
            (_) async => geolocator.LocationPermission.deniedForever);
        when(mockGeolocator.requestPermission()).thenAnswer(
            (_) async => geolocator.LocationPermission.deniedForever);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);

        GeolocatorPlatform.instance = mockGeolocator;

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              selectedCampus: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedCampus, 'SGW');
      });

      testWidgets('retrieves location after permission is granted',
          (WidgetTester tester) async {
        final mockGeolocator = MockGeolocatorPlatform();

        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockGeolocator.getCurrentPosition(
                locationSettings: anyNamed('locationSettings')))
            .thenAnswer((_) async => geolocator.Position(
                  latitude: 45.4979,
                  longitude: -73.5796,
                  timestamp: DateTime.now(),
                  accuracy: 1.0,
                  altitude: 0.0,
                  heading: 0.0,
                  speed: 0.0,
                  speedAccuracy: 0.0,
                  floor: null,
                  altitudeAccuracy: 0.0,
                  headingAccuracy: 0.0,
                ));

        GeolocatorPlatform.instance = mockGeolocator;

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              selectedCampus: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedCampus, 'SGW');
      });

      testWidgets('handles location services disabled',
          (WidgetTester tester) async {
        final mockGeolocator = MockGeolocatorPlatform();

        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => false);

        GeolocatorPlatform.instance = mockGeolocator;

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              selectedCampus: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedCampus, 'SGW');
      });

      testWidgets('handles error during location retrieval',
          (WidgetTester tester) async {
        final mockGeolocator = MockGeolocatorPlatform();

        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(mockGeolocator.getCurrentPosition(
                locationSettings: anyNamed('locationSettings')))
            .thenThrow(Exception('Location error'));

        GeolocatorPlatform.instance = mockGeolocator;

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              selectedCampus: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedCampus, 'SGW');
      });
    });
  });
}
