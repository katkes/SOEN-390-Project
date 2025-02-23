import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:soen_390/widgets/building_details.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CampusMap Widget Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        return null; // Reset any previous mock
      });
    });

    testWidgets('renders CampusMap widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CampusMap(),
        ),
      );

      expect(find.byType(CampusMap), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('loads building boundaries from GeoJSON',
        (WidgetTester tester) async {
      const mockGeoJson = '''
      {
        "features": [
          {
            "geometry": {
              "type": "Polygon",
              "coordinates": [
                [[-73.5862, 45.4965], [-73.5865, 45.4967], [-73.5868, 45.4964], [-73.5862, 45.4965]]
              ]
            }
          }
        ]
      }
      ''';

      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (ByteData? message) async {
          if (const StringCodec().decodeMessage(message) ==
              'assets/geojson_files/building_boundaries.geojson') {
            return const StringCodec().encodeMessage(mockGeoJson);
          }
          return null;
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: CampusMap(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PolygonLayer), findsOneWidget);
    });

    testWidgets('handles empty or malformed GeoJSON data gracefully',
        (WidgetTester tester) async {
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (ByteData? message) async {
          return const StringCodec().encodeMessage('{}');
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: CampusMap(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PolygonLayer), findsNothing);
    });
  });
}
