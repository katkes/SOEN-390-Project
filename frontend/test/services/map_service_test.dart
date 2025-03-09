//This test ensures that the loadBuildingMarkers method in MapService correctly loads and processes GeoJSON data to generate a list of building markers. The test begins by defining a mock GeoJSON string that represents a single building with its coordinates, name, and address. To simulate loading this data from Flutter’s asset system, a mock message handler is set up using TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(),
//which intercepts asset load requests and returns the mock GeoJSON data.
//Once the asset loading is mocked, the test calls loadBuildingMarkers(),
//passing in a placeholder callback function to process each marker.

import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:soen_390/widgets/search_bar.dart';

//Create a mock class for MapService
class MockMapService extends MapService {
  LatLng? mockedBuildingLocation;
  String? mockedCampus;
  List<String> mockedSuggestions = [];
  
  @override
  Future<Map<String, dynamic>?> searchBuildingWithDetails(String buildingName) async {
    if (mockedBuildingLocation != null) {
      return {
        'location': mockedBuildingLocation,
        'name': 'Test Building',
        'address': 'Test Address'
      };
    }
    return null;
  }
  
  @override
  Future<String?> findCampusForBuilding(String buildingName) async {
    return mockedCampus;
  }
  
  @override
  Future<List<String>> getBuildingSuggestions(String query) async {
    return mockedSuggestions;
  }
}

// Create a testable version of SearchBarWidget
class TestableSearchBarWidget extends SearchBarWidget {
  final MockMapService mockMapService;
  
  const TestableSearchBarWidget({
    Key? key,
    required TextEditingController controller,
    required this.mockMapService,
    Function(LatLng)? onLocationFound,
    Function(LatLng)? onBuildingSelected,
    Function(String)? onCampusSelected,
  }) : super(
    key: key,
    controller: controller,
    onLocationFound: onLocationFound,
    onBuildingSelected: onBuildingSelected,
    onCampusSelected: onCampusSelected,
  );
  
  
  @override
  TestableSearchBarWidgetState createState() => TestableSearchBarWidgetState();
}

class TestableSearchBarWidgetState extends SearchBarWidgetState {
  late final MapService _mapService;
  @override
  void initState() {
    super.initState();
    _mapService = (widget as TestableSearchBarWidget).mockMapService;
  }
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final MapService mapService = MapService();
  final MockMapService mockMapService = MockMapService();
  group('MapService', () {
    /// Tests marker loading functionality:
    /// - Loads GeoJSON data
    /// - Creates markers with correct coordinates
    /// - Sets up tap handlers
    /// - Verifies marker properties
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
      expect(markers.first.point, const LatLng(45.5017, -73.5673));
      expect(markers.first.child, isA<GestureDetector>());
    });
    /// Tests for loadBuildingPolygons() to verify that polygons are loaded and parsed correctly.
    test('loadBuildingPolygons loads and parses polygons', () async {
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
      expect(polygons.first.points.first, const LatLng(45.5017, -73.5673));
    });
  
  });
}
