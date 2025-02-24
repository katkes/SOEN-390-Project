//This tests the functionality of the outdoor_map.dart file. The components include:
// - The map widget
// - The markers
// - The polygons
// - The zoom constraints
// - The tile layer
// - The layout of the map widget
// - The markers for the SGW campus
// - The markers for the Loyola campus
// - The map widget with the correct layout

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart'; // Import the latlong2 package
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'building_outlines_test.mocks.dart';


@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mockHttpClient = MockClient();
  testWidgets('loads building boundaries from GeoJSON', (WidgetTester tester) async {
  
    const mockGeoJson = '''
    {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "MultiPolygon",
            "coordinates": [
              [
                [
                  [-73.58626591761417, 45.496459491762501],
                  [-73.586271264791804, 45.496525440286554],
                  [-73.586258788044006, 45.4965700001001],
                  [-73.586148279706407, 45.496715265092263],
                  [-73.585827449048864, 45.496581585651619],
                  [-73.585853293740726, 45.496500486790964],
                  [-73.58626591761417, 45.496459491762501]
                ]
              ]
            ]
          }
        }
      ]
    }
    ''';

   
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        final requestedAsset = const StringCodec().decodeMessage(message);
        if (requestedAsset == 'assets/geojson_files/building_boundaries.geojson') {
          return ByteData.sublistView(Uint8List.fromList(mockGeoJson.codeUnits));
        }
        return null;
      },
    );

    

    await tester.pumpWidget(
      MaterialApp(
        home: MapWidget(
          location: LatLng(45.496459, -73.586265),
          httpClient: mockHttpClient,
        ),
      ),
    );

    await tester.pumpAndSettle();


    expect(find.byType(PolygonLayer), findsOneWidget);
  });

  testWidgets('Markers load correctly', (WidgetTester tester) async {
    LatLng initialLocation = LatLng(45.4973, -73.5793);
    await tester.pumpWidget(MaterialApp(home: MapWidget(location: initialLocation, httpClient: mockHttpClient)));
    await tester.pumpAndSettle();

    expect(find.byType(MarkerLayer), findsOneWidget);
  });

  testWidgets('Polygons load correctly', (WidgetTester tester) async {
    LatLng initialLocation = LatLng(45.4973, -73.5793);
    await tester.pumpWidget(MaterialApp(home: MapWidget(location: initialLocation, httpClient: mockHttpClient)));
    await tester.pumpAndSettle();

    expect(find.byType(PolygonLayer), findsOneWidget);
  });

  testWidgets('Map updates when location changes', (WidgetTester tester) async {
    LatLng initialLocation = LatLng(45.4973, -73.5793);
    LatLng newLocation = LatLng(45.505, -73.57);

    await tester.pumpWidget(MaterialApp(home: MapWidget(location: initialLocation, httpClient: mockHttpClient)));
    await tester.pumpAndSettle();

    await tester.pumpWidget(MaterialApp(home: MapWidget(location: newLocation, httpClient: mockHttpClient)));
    await tester.pumpAndSettle();
  });
  

  testWidgets('Map respects zoom constraints', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapWidget(
          location: LatLng(45.4973, -73.5793),
          httpClient: mockHttpClient,
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    final mapFinder = find.byType(FlutterMap);
    final FlutterMap map = tester.widget(mapFinder);
    
    expect(map.options.minZoom, 11.0);
    expect(map.options.maxZoom, 17.0);
  });

  

  testWidgets('Tile layer is configured correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapWidget(
          location: LatLng(45.4973, -73.5793),
          httpClient: mockHttpClient,
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    final tileFinder = find.byType(TileLayer);
    expect(tileFinder, findsOneWidget);
    
    final TileLayer tileLayer = tester.widget(tileFinder);
    expect(tileLayer.urlTemplate, 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
  });

  testWidgets('Handles invalid GeoJSON gracefully', (WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        final requestedAsset = const StringCodec().decodeMessage(message);
        if (requestedAsset == 'assets/geojson_files/building_list.geojson') {
          return ByteData.sublistView(Uint8List.fromList('''
          {
            "type": "FeatureCollection",
            "features": [{
              "type": "Feature",
              "geometry": {
                "type": "InvalidType",
                "coordinates": "invalid"
              }
            }]
          }
          '''.codeUnits));
        }
        return null;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MapWidget(
          location: LatLng(45.4973, -73.5793),
          httpClient: mockHttpClient,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(FlutterMap), findsOneWidget);
  });
  testWidgets('renders MapWidget with correct layout', (WidgetTester tester) async {
      final LatLng testLocation = LatLng(0, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapWidget(
              location: testLocation,
              httpClient: mockHttpClient,
            ),
          ),
        ),
      );

      expect(find.byType(MapWidget), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  testWidgets('renders markers for SGW campus', (WidgetTester tester) async {
      final LatLng sgwLocation = LatLng(45.497856, -73.579588);

      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response('Mocked response', 200));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapWidget(
              location: sgwLocation,
              httpClient: mockHttpClient,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_pin), findsWidgets);
    });
}