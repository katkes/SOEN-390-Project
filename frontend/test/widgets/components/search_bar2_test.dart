/// Unit tests for the search bar functionality in the frontend
/// The tests ensure that the search bar behaves as expected
/// under various conditions, including input handling, search execution, and result
/// display. These tests help maintain the reliability and correctness of the search
/// feature in the application.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/search_bar.dart';
import 'package:latlong2/latlong.dart';

void main() {

  
testWidgets('Test performSearch triggers expected callbacks', (WidgetTester tester) async {
    // Create the test controller and callback functions
    final TextEditingController controller = TextEditingController();
    LatLng? locationFound;
    String? campusFound;
    
    // Create the SearchBarWidget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(
            controller: controller,
            onLocationFound: (location) {
              locationFound = location;
            },
            onBuildingSelected: (location) {
              locationFound = location;
            },
            onCampusSelected: (campus) {
              campusFound = campus;
            },
          ),
        ),
      ),
    );
     await tester.tap(find.byType(GestureDetector));
  await tester.pumpAndSettle();

  // Input text to simulate a search
  final searchField = find.byType(TextField);
  expect(searchField, findsOneWidget);

  // Simulate user typing into the search field
  await tester.enterText(searchField, 'Henry F. Hall Building');
  await tester.pumpAndSettle();  // Wait for animations to complete

  // Simulate pressing the submit button (Enter key)
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();  // Wait for the search to complete

  // Verify that the onLocationFound and onCampusSelected callbacks are called
  expect(locationFound, isNotNull);
  expect(campusFound, isNotNull);

  // You can also assert the campus value (assuming the map service returns "SGW")
  expect(campusFound, equals("SGW"));
  });

}
