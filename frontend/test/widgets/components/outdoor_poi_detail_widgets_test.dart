import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/outdoor_poi_detail_widgets.dart';

void main() {
  testWidgets('buildChip widget test', (WidgetTester tester) async {
    // Test: Verify that the buildChip widget displays the correct label and is a Chip widget.
    // Expected: The widget should contain the text 'Test Chip' and be of type Chip.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: buildChip('Test Chip', Colors.blue),
      ),
    ));

    expect(find.text('Test Chip'), findsOneWidget);
    expect(find.byType(Chip), findsOneWidget);
  });

  test('getPriceRangeString with symbol', () {
    // Test: Verify that getPriceRangeString returns the symbol when it exists.
    // Expected: The function should return '\$\$\$'.
    final priceRange = {'symbol': '\$\$\$', 'range': '20-50'};
    expect(getPriceRangeString(priceRange), '\$\$\$');
  });

  test('getPriceRangeString with range', () {
    // Test: Verify that getPriceRangeString returns the range when the symbol does not exist.
    // Expected: The function should return '20-50'.
    final priceRange = {'range': '20-50'};
    expect(getPriceRangeString(priceRange), '20-50');
  });

  test('getPriceRangeString with empty map', () {
    // Test: Verify that getPriceRangeString returns an empty string for an empty map.
    // Expected: The function should return ''.
    final priceRange = <String, dynamic>{};
    expect(getPriceRangeString(priceRange), '');
  });

  testWidgets('buildRatingStars with full stars', (WidgetTester tester) async {
    // Test: Verify that buildRatingStars displays the correct number of full stars.
    // Expected: The widget should display 4 full stars and 1 empty star.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: buildRatingStars(4.0),
      ),
    ));

    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('buildRatingStars with half star', (WidgetTester tester) async {
    // Test: Verify that buildRatingStars displays the correct number of full, half, and empty stars.
    // Expected: The widget should display 3 full stars, 1 half star, and 1 empty star.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: buildRatingStars(3.5),
      ),
    ));

    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_half), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('buildExpandableDescription shows limited lines initially',
      (WidgetTester tester) async {
    // Test: Verify that buildExpandableDescription initially shows limited lines and expands on tap.
    // Expected: The widget should initially display the description with a maximum of 3 lines and show 'Read more', then display full description and 'Show less' after tap.
    const description =
        'This is a long description to test the expandable description widget. This is a long description to test the expandable description widget. This is a long description to test the expandable description widget.';
    bool showFullDescription = false;
    void onToggle() {
      showFullDescription = !showFullDescription;
    }

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return buildExpandableDescription(description, showFullDescription,
                () {
              setState(() {
                onToggle();
              });
            }, context);
          },
        ),
      ),
    ));

    expect(find.text(description, findRichText: true), findsOneWidget);

    final textWidget = tester.widget<Text>(find.byType(Text).first);
    expect(textWidget.maxLines, 3);

    expect(find.text('Read more'), findsOneWidget);

    await tester.tap(find.text('Read more'));
    await tester.pumpAndSettle();

    final textWidget2 = tester.widget<Text>(find.byType(Text).first);
    expect(textWidget2.maxLines, null);

    expect(find.text('Show less'), findsOneWidget);
  });

  testWidgets('buildInfoRow handles onTap', (WidgetTester tester) async {
    // Test: Verify that buildInfoRow calls the onTap function when tapped.
    // Expected: The tapped variable should be true, indicating that the onTap function was called.
    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return buildInfoRow(
              Icons.phone,
              '123-456-7890',
              onTap: () {
                tapped = true;
              },
              context: context,
            );
          },
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.phone));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('buildInfoSection shows address, phone, and website',
      (WidgetTester tester) async {
    // Test: Verify that buildInfoSection displays address, phone, and website information.
    // Expected: The widget should display the address, phone, and website texts, and the corresponding icons.
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: buildInfoSection(
                '123 Main St', '123-456-7890', 'www.example.com', context),
          );
        },
      ),
    ));

    expect(find.text('123 Main St'), findsOneWidget);
    expect(find.text('123-456-7890'), findsOneWidget);
    expect(find.text('www.example.com'), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
    expect(find.byIcon(Icons.phone), findsOneWidget);
    expect(find.byIcon(Icons.language), findsOneWidget);
  });

  testWidgets('buildOpeningHoursSection displays opening hours',
      (WidgetTester tester) async {
    // Test: Verify that buildOpeningHoursSection displays the opening hours correctly.
    // Expected: The widget should display the days and their corresponding opening hours.
    final openingHours = {
      'Monday': '9:00 AM - 5:00 PM',
      'Tuesday': '9:00 AM - 5:00 PM',
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: buildOpeningHoursSection(openingHours),
      ),
    ));

    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('9:00 AM - 5:00 PM'), findsNWidgets(2));
    expect(find.text('Tuesday'), findsOneWidget);
  });

  testWidgets('buildAmenitiesSection displays amenities',
      (WidgetTester tester) async {
    // Test: Verify that buildAmenitiesSection displays the amenities as chip widgets.
    // Expected: The widget should display each amenity as a chip widget.
    final amenities = ['WiFi', 'Parking', 'Pool'];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: buildAmenitiesSection(amenities),
      ),
    ));

    expect(find.text('WiFi'), findsOneWidget);
    expect(find.text('Parking'), findsOneWidget);
    expect(find.text('Pool'), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(3));
  });
}
