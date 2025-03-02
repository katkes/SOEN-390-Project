/// This file contains tests to verify the behavior of the `CampusSwitch` widget.
/// The tests ensure that the initial selection is displayed correctly and that
/// switching between campuses updates the selection and triggers the appropriate
/// callbacks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/widgets/campus_switch_button.dart';

@GenerateMocks([geolocator.GeolocatorPlatform])
class MockGeolocatorPlatform extends Mock
    implements geolocator.GeolocatorPlatform {}

void main() {
  late MockGeolocatorPlatform mockGeolocator;

  setUp(() {
    // Create a new mock before each test
    mockGeolocator = MockGeolocatorPlatform();
    // Override the default instance:
    geolocator.GeolocatorPlatform.instance = mockGeolocator;
  });

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
        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.denied);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);

        when(mockGeolocator.getCurrentPosition())
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

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              initialSelection: 'Loyola',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as _CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });

      testWidgets('handles permission denied permanently',
          (WidgetTester tester) async {
        when(mockGeolocator.checkPermission()).thenAnswer(
            (_) async => geolocator.LocationPermission.deniedForever);
        when(mockGeolocator.requestPermission()).thenAnswer(
            (_) async => geolocator.LocationPermission.deniedForever);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);

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
            tester.state(find.byType(CampusSwitch)) as _CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });

      testWidgets('handles permission denied after request',
          (WidgetTester tester) async {
        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.denied);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.denied);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);

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
            tester.state(find.byType(CampusSwitch)) as _CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });

      testWidgets('retrieves location after permission is granted',
          (WidgetTester tester) async {
        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);

        when(mockGeolocator.getCurrentPosition())
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

        await tester.pumpWidget(
          MaterialApp(
            home: CampusSwitch(
              onSelectionChanged: (_) {},
              onLocationChanged: (_) {},
              initialSelection: 'Loyola',
            ),
          ),
        );

        await tester.pumpAndSettle();

        final state =
            tester.state(find.byType(CampusSwitch)) as _CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });

      testWidgets('handles location services disabled',
          (WidgetTester tester) async {
        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => false);

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
            tester.state(find.byType(CampusSwitch)) as _CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });

      testWidgets('handles error during location retrieval',
          (WidgetTester tester) async {
        when(mockGeolocator.checkPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.requestPermission())
            .thenAnswer((_) async => geolocator.LocationPermission.whileInUse);
        when(mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);

        when(mockGeolocator.getCurrentPosition())
            .thenThrow(Exception('Location error'));

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
            tester.state(find.byType(CampusSwitch)) as _CampusSwitchState;
        expect(state.selectedBuilding, 'SGW');
      });
    });
  });
}
