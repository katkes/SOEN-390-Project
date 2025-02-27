import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapService', () {
    testWidgets('loadBuildingMarkers returns a list of markers',
        (WidgetTester tester) async {
      final MapService mapService = MapService();
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
      expect(markers.first.point, LatLng(45.5017, -73.5673));
      expect(markers.first.child, isA<GestureDetector>());
    });
  });
}
