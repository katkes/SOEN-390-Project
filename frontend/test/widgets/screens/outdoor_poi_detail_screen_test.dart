import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/outdoor_poi/outdoor_poi_detail_screen.dart';
import 'package:soen_390/models/review.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/widgets/review_card.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  final testReview = Review(
    authorName: 'John Doe',
    authorUrl: 'https://example.com/profile',
    profilePhotoUrl: 'https://example.com/photo.jpg',
    rating: 5,
    relativeTimeDescription: '2 days ago',
    text: 'Great place!',
    time: DateTime.fromMillisecondsSinceEpoch(1610000000 * 1000),
  );

  final testPoi = PointOfInterest(
    id: 'poi_001',
    name: 'Sample Place',
    description: 'A nice place to visit.',
    imageUrl: 'https://example.com/image.jpg',
    address: '123 Street',
    contactPhone: '555-1234',
    website: 'https://example.com',
    openingHours: {'Monday': '9 AM - 5 PM'},
    amenities: ['WiFi', 'Parking'],
    rating: 4.5,
    category: 'Park',
    priceRange: '\$\$',
    reviews: [testReview],
    latitude: 45.5017,
    longitude: -73.5673,
  );

  group('PoiDetailScreen Widget Tests', () {
    testWidgets('renders POI details correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester
            .pumpWidget(MaterialApp(home: PoiDetailScreen(poi: testPoi)));
        await tester.pumpAndSettle();

        // App bar title
        expect(find.text('Sample Place'), findsOneWidget);

        // Category chip
        expect(find.text('Park'), findsOneWidget);

        // Rating & price range
        expect(find.text('4.5'), findsOneWidget);
        expect(find.text('\$\$'), findsOneWidget);

        // Description
        expect(find.text('A nice place to visit.'), findsOneWidget);

        // Contact Info
        expect(find.text('123 Street'), findsOneWidget);
        expect(find.text('555-1234'), findsOneWidget);
        expect(find.text('https://example.com'), findsOneWidget);

        // Scroll to bring amenities into view
        final scrollable = find.byType(Scrollable);
        await tester.fling(scrollable, const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Amenities
        expect(find.text('WiFi'), findsOneWidget);
        expect(find.text('Parking'), findsOneWidget);

        // Reviews
        expect(find.text('Reviews'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Great place!'), findsOneWidget);
      });
    });

    testWidgets('toggles expandable description', (WidgetTester tester) async {
      final longDescriptionPoi = PointOfInterest(
        id: testPoi.id,
        name: testPoi.name,
        description: 'This is a really long description ' * 10,
        imageUrl: testPoi.imageUrl,
        address: testPoi.address,
        contactPhone: testPoi.contactPhone,
        website: testPoi.website,
        openingHours: testPoi.openingHours,
        amenities: testPoi.amenities,
        rating: testPoi.rating,
        category: testPoi.category,
        priceRange: testPoi.priceRange,
        reviews: testPoi.reviews,
        latitude: testPoi.latitude,
        longitude: testPoi.longitude,
      );

      await tester.pumpWidget(
          MaterialApp(home: PoiDetailScreen(poi: longDescriptionPoi)));

      // Initially collapsed
      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('Show less'), findsNothing);

      // Tap "Read more"
      await tester.tap(find.text('Read more'));
      await tester.pumpAndSettle();

      expect(find.text('Show less'), findsOneWidget);
    });

    testWidgets('calls onBack callback when back button pressed',
        (WidgetTester tester) async {
      bool backPressed = false;
      void onBack() => backPressed = true;

      await tester.pumpWidget(MaterialApp(
        home: PoiDetailScreen(poi: testPoi, onBack: onBack),
      ));

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backPressed, true);
    });

    testWidgets('shows fallback image on image load error',
        (WidgetTester tester) async {
      final poiWithBadImage = PointOfInterest(
        id: testPoi.id,
        name: testPoi.name,
        description: testPoi.description,
        imageUrl: 'https://invalid.url/image.jpg',
        address: testPoi.address,
        contactPhone: testPoi.contactPhone,
        website: testPoi.website,
        openingHours: testPoi.openingHours,
        amenities: testPoi.amenities,
        rating: testPoi.rating,
        category: testPoi.category,
        priceRange: testPoi.priceRange,
        reviews: testPoi.reviews,
        latitude: testPoi.latitude,
        longitude: testPoi.longitude,
      );
      await tester
          .pumpWidget(MaterialApp(home: PoiDetailScreen(poi: poiWithBadImage)));

      final image = find.byType(Image);
      expect(image, findsOneWidget);

      // Simulate image load error
      final errorBuilder = tester.widget<Image>(image).errorBuilder;
      expect(errorBuilder, isNotNull);
    });

    testWidgets('renders correctly with missing optional fields',
        (WidgetTester tester) async {
      final minimalPoi = PointOfInterest(
        id: 'poi_002',
        name: 'Minimal Place',
        description: 'Just a place.',
        imageUrl: null,
        address: null,
        contactPhone: null,
        website: null,
        openingHours: {},
        amenities: [],
        rating: null,
        category: null,
        priceRange: null,
        reviews: [],
        latitude: testPoi.latitude,
        longitude: testPoi.longitude,
      );

      await tester
          .pumpWidget(MaterialApp(home: PoiDetailScreen(poi: minimalPoi)));

      expect(find.text('Minimal Place'), findsOneWidget);
      expect(find.text('Just a place.'), findsOneWidget);

      // Optional fields not shown
      expect(find.text('Amenities'), findsNothing);
      expect(find.text('Reviews'), findsNothing);
      expect(find.byType(ReviewCard), findsNothing);
    });
  });
}
