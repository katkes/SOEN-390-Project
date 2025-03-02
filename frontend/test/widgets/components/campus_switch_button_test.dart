/// This file contains tests to verify the behavior of the `CampusSwitch` widget.
/// The tests ensure that the initial selection is displayed correctly and that
/// switching between campuses updates the selection and triggers the appropriate
/// callbacks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:soen_390/widgets/campus_switch_button.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {
  @override
  Future<geolocator.LocationPermission> checkPermission() => super.noSuchMethod(
        Invocation.method(#checkPermission, []),
        returnValue: Future.value(geolocator.LocationPermission.denied),
      ) as Future<geolocator.LocationPermission>;

  @override
  Future<geolocator.LocationPermission> requestPermission() =>
      super.noSuchMethod(
        Invocation.method(#requestPermission, []),
        returnValue: Future.value(geolocator.LocationPermission.whileInUse),
      ) as Future<geolocator.LocationPermission>;

  @override
  Future<bool> isLocationServiceEnabled() => super.noSuchMethod(
        Invocation.method(#isLocationServiceEnabled, []),
        returnValue: Future.value(true),
      ) as Future<bool>;

  @override
  Future<geolocator.Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) =>
      super.noSuchMethod(
        Invocation.method(
            #getCurrentPosition, [], {#locationSettings: locationSettings}),
        returnValue: Future.value(geolocator.Position(
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
        )),
      ) as Future<geolocator.Position>;
}

void main() {
  group('CampusSwitch Widget Tests', () {
    testWidgets('displays initial selection correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CampusSwitch(
            onSelectionChanged: (_) {},
            onLocationChanged: (_) {},
            initialSelection: 'SGW',
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
            initialSelection: 'SGW',
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

        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.denied);
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
              initialSelection: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
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
              initialSelection: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });

      testWidgets('handles permission denied after request',
          (WidgetTester tester) async {
        final mockGeolocator = MockGeolocatorPlatform();

        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.denied);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.denied);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);

        GeolocatorPlatform.instance = mockGeolocator;

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              initialSelection: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
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
              initialSelection: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
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
              initialSelection: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
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
              initialSelection: 'SGW',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });
    });
  });
}
