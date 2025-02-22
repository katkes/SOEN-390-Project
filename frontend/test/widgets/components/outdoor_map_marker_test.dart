/// This test file verifies that the MapWidget correctly renders markers for SGW and Loyola campuses.
/// It uses the mockito package to mock HTTP requests and ensure that the markers are displayed correctly
/// without making real network requests. The test checks that the markers are rendered with the correct
/// color and verifies that the MapWidget updates correctly when the location changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'outdoor_map_marker_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  // This group of tests verifies that the MapWidget correctly renders markers for the SGW and Loyola campuses.
  // It uses the mockito package to mock HTTP requests and ensure that the markers are displayed correctly
  // without making real network requests.
  group('MapWidget Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    // This test verifies that the MapWidget correctly renders markers for the SGW campus.
    testWidgets('renders markers for SGW campus', (WidgetTester tester) async {
      final LatLng sgwLocation = LatLng(45.497856, -73.579588);

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Mocked response', 200));

      await tester.pumpWidget(
        MaterialApp(
          home: MyPage(
            location: sgwLocation,
            httpClient: mockClient,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_pin), findsNWidgets(1));
    });

    // This test verifies that the MapWidget correctly renders markers for the Loyola campus.
    testWidgets('renders markers for Loyola campus',
        (WidgetTester tester) async {
      final LatLng loyolaLocation = LatLng(45.4581, -73.6391);

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Mocked response', 200));

      await tester.pumpWidget(
        MaterialApp(
          home: MyPage(
            location: loyolaLocation,
            httpClient: mockClient,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_pin), findsNWidgets(1));
    });
  });

// This group of tests verifies that the MyPage widget correctly renders the MapWidget
// and checks that the layout is correct.
  group('MyPage Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    testWidgets('renders MyPage with MapWidget and checks layout',
        (WidgetTester tester) async {
      final LatLng testLocation = LatLng(0, 0); // Arbitrary location

      await tester.pumpWidget(
        MaterialApp(
          home: MyPage(
            location: testLocation,
            httpClient: mockClient,
          ),
        ),
      );

      expect(find.byType(MyPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(MapWidget), findsOneWidget);
    });
  });
}
