/// Unit tests for the `SuggestionsPopup` widget.
///
/// These tests verify the correct behavior of the `SuggestionsPopup` widget, including:
/// - Rendering of the widget and its components, such as the text field.
/// - Correct filtering and display of suggestions based on user input.
/// - Proper interaction with the widget, including selecting a suggestion and updating the callback.
/// - Verifying that the widget correctly simulates API calls and populates suggestions based on input.
///
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/widgets/suggestions.dart';

void main() {
  testWidgets('SuggestionsPopup renders correctly',
      (WidgetTester tester) async {
    // Set the environment variable for testing
    dotenv.testLoad(fileInput: 'GOOGLE_PLACES_API_KEY=mock-api-key');

    // Define a callback for onSelect
    String selectedSuggestion = '';

    // Build SuggestionsPopup widget
    await tester.pumpWidget(MaterialApp(
      home: SuggestionsPopup(onSelect: (selected) {
        selectedSuggestion = selected;
      }),
    ));

    // Check if text field is present
    expect(find.byType(TextField), findsOneWidget);

    // Simulate user typing
    await tester.enterText(find.byType(TextField), 'restaurant');
    await tester.pump(); // Rebuild widget

    // Check if filtered suggestions are displayed
    expect(find.text('Restaurant'), findsOneWidget);

    // Simulate selection of a suggestion
    await tester.tap(find.text('Restaurant'));
    await tester.pump(); // Rebuild widget

    // Ensure the callback was called with the correct value
    expect(selectedSuggestion, 'Restaurant');
  });

  testWidgets('SuggestionsPopup calls API on search',
      (WidgetTester tester) async {
    // Set the environment variable for testing
    dotenv.testLoad(fileInput: 'GOOGLE_PLACES_API_KEY=mock-api-key');

    String selectedSuggestion = '';

    await tester.pumpWidget(MaterialApp(
      home: SuggestionsPopup(onSelect: (selected) {
        selectedSuggestion = selected;
      }),
    ));

    // Simulate user typing 'coffee' in the text field
    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pump(); // Rebuild widget

    // Check if suggestions list is populated (simulating API response)
    expect(find.text('Coffee'), findsOneWidget);

    // Simulate selecting a suggestion
    await tester.tap(find.text('Coffee'));
    await tester.pump(); // Rebuild widget

    // Ensure the correct callback was triggered
    expect(selectedSuggestion, 'Coffee');
  });
}
