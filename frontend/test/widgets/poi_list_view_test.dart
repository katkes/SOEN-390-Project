import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/widgets/poi_list_view.dart';

void main() {
  const testApiKey = 'TEST_API_KEY';

  final place1 = Place(
    name: 'Test Place 1',
    placeId: 'place_001',
    businessStatus: 'OPERATIONAL',
    latitude: 40.0,
    longitude: -73.0,
    address: '123 Main St',
    types: ['restaurant'],
    rating: 4.5,
    userRatingsTotal: 100,
    priceLevel: 2,
    openNow: true,
    photoReference: 'photo_ref_001',
    iconUrl: '',
    plusCode: null,
  );

  final place2 = Place(
    name: 'Test Place 2',
    placeId: 'place_002',
    businessStatus: 'OPERATIONAL',
    latitude: 41.0,
    longitude: -74.0,
    address: '456 Side St',
    types: ['museum'],
    rating: 4.0,
    userRatingsTotal: 50,
    priceLevel: 1,
    openNow: false,
    photoReference: null,
    iconUrl: '',
    plusCode: null,
  );

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('Displays empty state when no places are available',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      POIListView(places: [], apiKey: testApiKey, onPlaceTap: (_) {}),
    ));

    expect(find.text('No places found.'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('Renders list of places with POICards',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createTestWidget(
        POIListView(
            places: [place1, place2], apiKey: testApiKey, onPlaceTap: (_) {}),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Test Place 1'), findsOneWidget);
      expect(find.text('Test Place 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  testWidgets('Tapping a POICard triggers onPlaceTap with correct place',
      (WidgetTester tester) async {
    Place? tappedPlace;

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createTestWidget(
        POIListView(
          places: [place1],
          apiKey: testApiKey,
          onPlaceTap: (place) {
            tappedPlace = place;
          },
        ),
      ));

      await tester.pumpAndSettle();

      // Tap the POICard
      await tester.tap(find.text('Test Place 1'));
      await tester.pump(); // Allow tap to register

      expect(tappedPlace, isNotNull);
      expect(tappedPlace!.name, 'Test Place 1');
    });
  });
}
