//This test ensures that the loadBuildingMarkers method in MapService correctly loads and processes GeoJSON data to generate a list of building markers. The test begins by defining a mock GeoJSON string that represents a single building with its coordinates, name, and address. To simulate loading this data from Flutter’s asset system, a mock message handler is set up using TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(),
//which intercepts asset load requests and returns the mock GeoJSON data.
//Once the asset loading is mocked, the test calls loadBuildingMarkers(),
//passing in a placeholder callback function to process each marker.

import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:latlong2/latlong.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapService', () {
    /// Tests marker loading functionality:
    /// - Loads GeoJSON data
    /// - Creates markers with correct coordinates
    /// - Sets up tap handlers
    /// - Verifies marker properties
    testWidgets('loadBuildingMarkers returns a list of markers',
        (WidgetTester tester) async {
      final MapService mapService = MapService();

      // Ensure _selectedMarkerLocation is non-null by selecting a marker location.
      mapService.selectPolygon(const LatLng(45.5017, -73.5673));
      const String mockGeoJson = '''
      {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [-73.5673, 45.5017]
            },
            "properties": {
              "Building Long Name": "Test Building",
              "Address": "123 Test St"
            }
          }
        ]
      }
      ''';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (message) async =>
            ByteData.view(Uint8List.fromList(utf8.encode(mockGeoJson)).buffer),
      );

      final markers = await mapService
          .loadBuildingMarkers((lat, lon, name, address, position) {});

      expect(markers, isNotEmpty);
      expect(markers.first.point, equals(const LatLng(45.5017, -73.5673)));

      // Pump the tester to let the timer (from selectMarker) complete.
      await tester.pump(const Duration(seconds: 8));
    });

    testWidgets('loadBuildingPolygons loads and parses polygons',
        (WidgetTester tester) async {
      final MapService mapService = MapService();
      const String mockGeoJson = '''
      {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "geometry": {
              "type": "MultiPolygon",
              "coordinates": [
                [[[-73.5673, 45.5017], [-73.5674, 45.5018], [-73.5673, 45.5019], [-73.5673, 45.5017]]]
              ]
            },
            "properties": {
              "Building Long Name": "Test Polygon"
            }
          }
        ]
      }
      ''';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (message) async =>
            ByteData.view(Uint8List.fromList(utf8.encode(mockGeoJson)).buffer),
      );

      final polygons = await mapService.loadBuildingPolygons();

      expect(polygons, isNotEmpty);
      expect(polygons.first.points, isNotEmpty);
      expect(
          polygons.first.points.first, equals(const LatLng(45.5017, -73.5673)));
    });

    testWidgets('startClearTimer sets timer and clears marker location',
        (WidgetTester tester) async {
      final MapService mapService = MapService();
      final LatLng testLocation = const LatLng(45.5017, -73.5673);

      // Set the marker and start the timer.
      mapService.selectPolygon(testLocation);
      expect(mapService.selectedPolygonLocation, equals(testLocation));

      // Pump enough time for the timer to fire.
      await tester.pump(const Duration(seconds: 8));

      expect(mapService.selectedPolygonLocation, isNull);
    });

    testWidgets('startClearTimer calls onMarkerCleared callback',
        (WidgetTester tester) async {
      final MapService mapService = MapService();
      final LatLng testLocation = const LatLng(45.5017, -73.5673);
      mapService.selectPolygon(testLocation);

      bool callbackCalled = false;
      mapService.onPolygonCleared = () {
        callbackCalled = true;
      };

      // Pump enough time for the timer callback to be invoked.
      await tester.pump(const Duration(seconds: 8));

      expect(callbackCalled, isTrue);
    });

    testWidgets('startClearTimer cancels previous timer if called again',
        (WidgetTester tester) async {
      final MapService mapService = MapService();
      final LatLng testLocation = const LatLng(45.5017, -73.5673);
      mapService.selectPolygon(testLocation);

      bool callbackCalled = false;
      mapService.onPolygonCleared = () {
        callbackCalled = true;
      };

      // Pump a bit of time (3 seconds) then call startClearTimer again
      // to cancel the previous timer.
      await tester.pump(const Duration(seconds: 3));
      mapService.startClearTimer();

      // Pump additional time to allow the new timer to fire.
      await tester.pump(const Duration(seconds: 8));

      expect(callbackCalled, isTrue);
      expect(mapService.selectedPolygonLocation, isNull);
    });
  });
}
