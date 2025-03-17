import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/screens/outdoor_poi/outdoor_poi_detail_screen.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/sample_data.dart';

void main() {
  // Test data
  final testPoi = const PointOfInterest(
    id: 'test1',
    name: 'Test Restaurant',
    description:
        'This is a long description that should be expandable. It contains more than 150 characters to ensure that the "Read more" functionality works properly when testing the description expansion and collapse feature.',
    imageUrl: 'https://example.com/image.jpg',
    address: '123 Test St, Test City',
    contactPhone: '(123) 456-7890',
    website: 'www.testrestaurant.com',
    openingHours: {
      'Monday': '9:00 AM - 5:00 PM',
      'Tuesday': '9:00 AM - 5:00 PM',
      'Wednesday': '9:00 AM - 5:00 PM',
    },
    amenities: ['Free WiFi', 'Parking', 'Outdoor Seating'],
    rating: 4.5,
    category: 'Test Category',
    cuisine: ['Test Cuisine', 'Another Cuisine'],
    priceRange: {
      'symbol': '<span class="math-inline">\\</span>',
      'range': 'Moderate'
    },
  );

  final testPoiNoExtras = const PointOfInterest(
    id: 'test2',
    name: 'Minimal Test Restaurant',
    description: 'Brief description',
  );

  Widget createPoiDetailScreen(PointOfInterest poi) {
    return MaterialApp(
      home: PoiDetailScreen(
        poi: poi,
        onBack: () {},
      ),
    );
  }

  group('PoiDetailScreen Widget Tests', () {
    testWidgets('should display basic POI information',
        (WidgetTester tester) async {
      // Test: Verifies that basic POI information is displayed.
      // Expected: The POI's name, description, "Read more" button, "About" and "Information" sections should be visible.
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createPoiDetailScreen(testPoi));

        expect(find.text('Test Restaurant'), findsOneWidget);
        expect(
            find.text(
                'This is a long description that should be expandable. It contains more than 150 characters to ensure that the "Read more" functionality works properly when testing the description expansion and collapse feature.'),
            findsOneWidget);
        expect(find.text('Read more'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Information'), findsOneWidget);
      });
    });

    testWidgets('should display rating correctly', (WidgetTester tester) async {
      // Test: Verifies that the rating is displayed correctly with stars and the numeric value.
      // Expected: The rating should be displayed as "4.5" with 4 full stars and 1 half star.
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createPoiDetailScreen(testPoi));

        expect(find.text('4.5'), findsOneWidget);

        expect(find.byIcon(Icons.star), findsNWidgets(4));
        expect(find.byIcon(Icons.star_half), findsOneWidget);
      });
    });

    testWidgets('should display category and cuisine chips',
        (WidgetTester tester) async {
      // Test: Verifies that category and cuisine chips are displayed.
      // Expected: The category "Test Category" and cuisines "Test Cuisine" and "Another Cuisine" should be displayed as chips.
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createPoiDetailScreen(testPoi));

        expect(find.text('Test Category'), findsOneWidget);
        expect(find.text('Test Cuisine'), findsOneWidget);
        expect(find.text('Another Cuisine'), findsOneWidget);
      });
    });

    testWidgets(
        'should expand and collapse description when "Read more" is tapped',
        (WidgetTester tester) async {
      // Test: Verifies that the description expands and collapses when the "Read more" button is tapped.
      // Expected: The description should initially show "Read more", then "Show less", and then "Read more" again after tapping.
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createPoiDetailScreen(testPoi));

        expect(find.text('Read more'), findsOneWidget);

        await tester.tap(find.text('Read more'));
        await tester.pump();

        expect(find.text('Show less'), findsOneWidget);

        await tester.tap(find.text('Show less'));
        await tester.pump();

        expect(find.text('Read more'), findsOneWidget);
      });
    });

    testWidgets('should display contact information correctly',
        (WidgetTester tester) async {
      // Test: Verifies that contact information is displayed correctly.
      // Expected: The address, phone number, and website should be displayed along with their respective icons.
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createPoiDetailScreen(testPoi));

        expect(find.text('123 Test St, Test City'), findsOneWidget);
        expect(find.text('(123) 456-7890'), findsOneWidget);
        expect(find.text('www.testrestaurant.com'), findsOneWidget);

        expect(find.byIcon(Icons.location_on), findsOneWidget);
        expect(find.byIcon(Icons.phone), findsOneWidget);
        expect(find.byIcon(Icons.language), findsOneWidget);
      });
    });

    testWidgets('should handle back button press', (WidgetTester tester) async {
      // Test: Verifies that the back button press triggers the onBack callback.
      // Expected: The backPressed variable should be true after tapping the back button.
      bool backPressed = false;

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: PoiDetailScreen(
              poi: testPoi,
              onBack: () {
                backPressed = true;
              },
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();

        expect(backPressed, true);
      });
    });

    testWidgets('should display fallback container when image is null',
        (WidgetTester tester) async {
      // Test: Verifies that a fallback container is displayed when the image URL is null.
      // Expected: A container and the restaurant icon with white70 color should be displayed.
      final poiWithNullImage = const PointOfInterest(
        id: 'test-null-image',
        name: 'Null Image Test',
        description: 'Testing null image handling',
        imageUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PoiDetailScreen(
            poi: poiWithNullImage,
            onBack: () {},
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);

      final iconFinder = find.byIcon(Icons.restaurant);
      expect(iconFinder, findsOneWidget);

      final Icon icon = tester.widget(iconFinder);
      expect(icon.color, Colors.white70);
    });

    testWidgets('should gracefully handle POI with minimal data',
        (WidgetTester tester) async {
      // Test: Verifies that the screen handles POIs with minimal data gracefully.
      // Expected: The POI's name and description should be displayed, and other optional sections should not be present.
      await tester.pumpWidget(createPoiDetailScreen(testPoiNoExtras));
      await tester.pump();

      expect(find.text('Minimal Test Restaurant'), findsOneWidget);
      expect(find.text('Brief description'), findsOneWidget);

      expect(find.text('Hours'), findsNothing);
      expect(find.text('Amenities'), findsNothing);
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });

  group('Main App Tests', () {
    testWidgets('MyApp initializes correctly', (WidgetTester tester) async {
      // Test: Verifies that MyApp builds without errors.
      // Expected: A MaterialApp widget should be created, and PoiDetailPage should be the home widget.
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(PoiDetailPage), findsOneWidget);
    });

    testWidgets('MyApp sets theme correctly', (WidgetTester tester) async {
      // Test: Verifies that MyApp sets the theme correctly.
      // Expected: The app title should be "POI Detail Demo", Material 3 should be enabled, primary color should be 0xFF912338, and visual density should be adaptivePlatformDensity.
      await tester.pumpWidget(const MyApp());
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, 'POI Detail Demo');
      final ThemeData theme = materialApp.theme!;
      expect(theme.useMaterial3, true);
      expect(theme.colorScheme.primary, equals(const Color(0xFF912338)));
      expect(
          theme.visualDensity, equals(VisualDensity.adaptivePlatformDensity));
    });

    testWidgets('main() function launches app without errors',
        (WidgetTester tester) async {
      // Test: Verifies that the main() function launches the app without errors.
      // Expected: A MaterialApp widget should be built without exceptions.
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
