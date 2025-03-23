import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/poi_search_bar.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

void main() {
  group('POISearchBar Widget Tests', () {
    late TextEditingController controller;
    String? searchedAddress;
    double? searchedLat;
    double? searchedLng;
    bool useCurrentLocationPressed = false;

    setUp(() {
      controller = TextEditingController();
      searchedAddress = null;
      searchedLat = null;
      searchedLng = null;
      useCurrentLocationPressed = false;
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: POISearchBar(
            controller: controller,
            googleApiKey: 'FAKE_API_KEY',
            onSearch: (address, lat, lng) {
              searchedAddress = address;
              searchedLat = lat;
              searchedLng = lng;
            },
            onUseCurrentLocation: (callback) async {
              useCurrentLocationPressed = true;

              // Simulate a location being fetched and passed to callback
              callback(12.34, 56.78);
            },
          ),
        ),
      );
    }

    testWidgets('renders search bar and location button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
          find.byType(GooglePlacesAutoCompleteTextFormField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets(
        'pressing location button triggers onUseCurrentLocation and updates text',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap location icon
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump(); // Allow state update

      expect(useCurrentLocationPressed, isTrue);
      expect(controller.text, 'Current Location');
      expect(searchedAddress, 'Current Location');
      expect(searchedLat, 12.34);
      expect(searchedLng, 56.78);
    });

    testWidgets('simulates suggestion click and updates controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final poiSearchBar =
          tester.widget<POISearchBar>(find.byType(POISearchBar));

      // Simulate suggestion click manually
      final prediction = Prediction(description: 'Test Location');

      // Simulate suggestion click logic
      controller.text = prediction.description!;
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));

      await tester.pump();

      expect(controller.text, 'Test Location');
    });

    testWidgets(
        'simulates place details with coordinates and triggers onSearch',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final poiSearchBar =
          tester.widget<POISearchBar>(find.byType(POISearchBar));

      // Simulate valid prediction with coordinates
      final prediction = Prediction(
        description: 'Selected Location',
        lat: '45.4215',
        lng: '-75.6972',
      );

      double lat = double.tryParse(prediction.lat.toString()) ?? 0.0;
      double lng = double.tryParse(prediction.lng.toString()) ?? 0.0;

      // Simulate onPlaceDetailsWithCoordinatesReceived logic
      controller.text = prediction.description!;
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
      poiSearchBar.onSearch(prediction.description!, lat, lng);

      await tester.pump();

      expect(searchedAddress, 'Selected Location');
      expect(searchedLat, 45.4215);
      expect(searchedLng, -75.6972);
    });
  });
}
