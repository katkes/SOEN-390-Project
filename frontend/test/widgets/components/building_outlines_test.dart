library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/widgets/building_details.dart';
//import 'package:soen_390/widgets/building_details.dart'; // Ensure this import is correct
import 'building_outlines_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  group('CampusMap Widget Tests', () {
    testWidgets('renders CampusMap widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CampusMap(httpClient: mockClient),
        ),
      );

      expect(find.byType(CampusMap), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // testWidgets('loads building boundaries from GeoJSON', (WidgetTester tester) async {
    //   const mockGeoJson = '''
    //   {
    //     "type": "FeatureCollection",
    //     "features": [
    //       {
    //         "type": "Feature",
    //         "geometry": {
    //           "type": "Polygon",
    //           "coordinates": [
    //             [[-73.5862, 45.4965], [-73.5865, 45.4967], [-73.5868, 45.4964], [-73.5862, 45.4965]]
    //           ]
    //         }
    //       }
    //     ]
    //   }
    //   ''';
    //
    //   when(mockClient.get(any)).thenAnswer((_) async => http.Response(mockGeoJson, 200));
    //
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: CampusMap(httpClient: mockClient),
    //     ),
    //   );
    //
    //   await tester.pumpAndSettle();
    //
    //   verify(mockClient.get(any)).called(1);
    //   expect(find.byType(PolygonLayer), findsOneWidget);
    // });

    testWidgets('handles empty or malformed GeoJSON data gracefully', (WidgetTester tester) async {
      when(mockClient.get(any)).thenAnswer((_) async => http.Response('{}', 200));

      await tester.pumpWidget(
        MaterialApp(
          home: CampusMap(httpClient: mockClient),
        ),
      );

      await tester.pumpAndSettle();

      verify(mockClient.get(any)).called(1);
      expect(find.byType(PolygonLayer), findsNothing);
    });

    testWidgets('does not call API when it is not needed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CampusMap(), // No httpClient passed, should use local asset
        ),
      );

      await tester.pumpAndSettle();

      verifyNever(mockClient.get(any));
    });

  });
}
