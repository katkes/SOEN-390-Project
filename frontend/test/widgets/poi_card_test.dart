import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/widgets/poi_card.dart';

void main() {
  const testApiKey = 'TEST_API_KEY';

  final placeWithPhoto = Place(
    name: 'Test Place',
    placeId: 'place_123',
    businessStatus: 'OPERATIONAL',
    latitude: 40.7128,
    longitude: -74.0060,
    address: 'New York, NY',
    types: ['restaurant', 'bar'],
    rating: 4.5,
    userRatingsTotal: 200,
    priceLevel: 2,
    openNow: true,
    photoReference: 'photo_ref_123',
    iconUrl: 'https://example.com/icon.png',
    plusCode: '87G8+XF New York',
  );

  final placeWithoutPhoto = Place(
    name: 'No Photo Place',
    placeId: 'place_456',
    businessStatus: 'OPERATIONAL',
    latitude: 34.0522,
    longitude: -118.2437,
    address: 'Los Angeles, CA',
    types: ['museum'],
    rating: 4.2,
    userRatingsTotal: 150,
    priceLevel: null,
    openNow: null,
    photoReference: null,
    iconUrl: 'https://example.com/icon.png',
    plusCode: null,
  );

  Widget createTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('POICard renders correctly with photo',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
          createTestWidget(POICard(place: placeWithPhoto, apiKey: testApiKey)));
      await tester.pumpAndSettle();

      // Verify name
      expect(find.text('Test Place'), findsOneWidget);

      // Verify types + rating summary
      expect(
          find.text('Restaurant, Bar • 4.5 ★ (200 reviews)'), findsOneWidget);

      // Verify open status
      expect(find.text('Open Now'), findsOneWidget);

      // Verify image loaded (Image.network used)
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });

  testWidgets('POICard renders correctly without photo',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createTestWidget(
          POICard(place: placeWithoutPhoto, apiKey: testApiKey)));
      await tester.pumpAndSettle();

      expect(find.text('No Photo Place'), findsOneWidget);
      expect(find.text('Museum • 4.2 ★ (150 reviews)'), findsOneWidget);
      expect(find.text('Unknown Hours'), findsOneWidget);

      // Fallback to Icon if no image
      expect(find.byIcon(Icons.place), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });

  testWidgets('POICard truncates long subtitle text',
      (WidgetTester tester) async {
    final placeWithLongTypes = Place(
      name: 'Long Type Place',
      placeId: 'place_789',
      businessStatus: 'OPERATIONAL',
      latitude: 48.8566,
      longitude: 2.3522,
      address: 'Paris, France',
      types: ['tourist_attraction', 'historical_landmark', 'museum'],
      rating: 5.0,
      userRatingsTotal: 999,
      priceLevel: 3,
      openNow: false,
      photoReference: null,
      iconUrl: '',
      plusCode: null,
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createTestWidget(
          POICard(place: placeWithLongTypes, apiKey: testApiKey)));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tourist attraction'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
    });
  });
}
