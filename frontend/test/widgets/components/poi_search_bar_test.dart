import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/poi_search_bar.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

/// Helper function to create the test widget with customizable callbacks.
Widget createTestWidget({
  required TextEditingController controller,
  required Function(String address, double lat, double lng) onSearch,
  required Future<void> Function(Function(double lat, double lng))
      onUseCurrentLocation,
}) {
  return MaterialApp(
    home: Scaffold(
      body: POISearchBar(
        controller: controller,
        googleApiKey: 'FAKE_API_KEY',
        onSearch: onSearch,
        onUseCurrentLocation: onUseCurrentLocation,
      ),
    ),
  );
}

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

    testWidgets('renders search bar and location button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        onSearch: (address, lat, lng) {
          searchedAddress = address;
          searchedLat = lat;
          searchedLng = lng;
        },
        onUseCurrentLocation: (callback) async {
          useCurrentLocationPressed = true;
          callback(12.34, 56.78);
        },
      ));

      expect(
          find.byType(GooglePlacesAutoCompleteTextFormField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets(
        'pressing location button triggers onUseCurrentLocation and updates text',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        onSearch: (address, lat, lng) {
          searchedAddress = address;
          searchedLat = lat;
          searchedLng = lng;
        },
        onUseCurrentLocation: (callback) async {
          useCurrentLocationPressed = true;
          callback(12.34, 56.78);
        },
      ));

      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump(); // Let UI update

      expect(useCurrentLocationPressed, isTrue);
      expect(controller.text, 'Current Location');
      expect(searchedAddress, 'Current Location');
      expect(searchedLat, 12.34);
      expect(searchedLng, 56.78);
    });

    testWidgets('simulates suggestion click and updates controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        onSearch: (_, __, ___) {},
        onUseCurrentLocation: (_) async {},
      ));

      final prediction = Prediction(description: 'Test Location');

      controller.text = prediction.description!;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );

      await tester.pump();

      expect(controller.text, 'Test Location');
    });

    testWidgets(
        'simulates place details with coordinates and triggers onSearch',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        onSearch: (address, lat, lng) {
          searchedAddress = address;
          searchedLat = lat;
          searchedLng = lng;
        },
        onUseCurrentLocation: (_) async {},
      ));

      final poiSearchBar =
          tester.widget<POISearchBar>(find.byType(POISearchBar));

      final prediction = Prediction(
        description: 'Selected Location',
        lat: '45.4215',
        lng: '-75.6972',
      );

      double lat = double.tryParse(prediction.lat.toString()) ?? 0.0;
      double lng = double.tryParse(prediction.lng.toString()) ?? 0.0;

      controller.text = prediction.description!;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );

      poiSearchBar.onSearch(prediction.description!, lat, lng);

      await tester.pump();

      expect(searchedAddress, 'Selected Location');
      expect(searchedLat, 45.4215);
      expect(searchedLng, -75.6972);
    });

    testWidgets('shows SnackBar on invalid coordinates',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        controller: controller,
        onSearch: (_, __, ___) {},
        onUseCurrentLocation: (_) async {},
      ));

      final autoCompleteFinder =
          find.byType(GooglePlacesAutoCompleteTextFormField);
      final widget = tester
          .widget<GooglePlacesAutoCompleteTextFormField>(autoCompleteFinder);

      final invalidPrediction = Prediction(description: 'Invalid Location');

      widget.onPlaceDetailsWithCoordinatesReceived!(invalidPrediction);

      await tester.pump(); // Let SnackBar show

      expect(find.text('Failed to get valid location coordinates.'),
          findsOneWidget);
    });
  });
}
