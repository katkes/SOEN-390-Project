import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/widgets/outdoor_map.dart';

void main() {
  group('MapRectangle Widget Tests', () {
    final LatLng testLocation = LatLng(45.497856, -73.579588);

    testWidgets('renders map correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapRectangle(location: testLocation),
          ),
        ),
      );

      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('loads markers successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapRectangle(location: testLocation),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(MarkerLayer), findsOneWidget);
    });

  });
}