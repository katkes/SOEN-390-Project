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
  testWidgets('SuggestionsPopup displays suggestions',
      (WidgetTester tester) async {
    // Define a mock onSelect function
    void mockOnSelect(String suggestion) {}

    // Build the SuggestionsPopup widget inside a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionsPopup(onSelect: mockOnSelect),
        ),
      ),
    );

    // Wait for any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Verify the SuggestionsPopup displays the suggestions with correct information
    expect(find.text("Restaurant"), findsOneWidget);
    expect(find.text("Fast Food"), findsOneWidget);
    expect(find.text("Coffee"), findsOneWidget);
    expect(find.text("Dessert"), findsOneWidget);
    expect(find.text("Shopping"), findsOneWidget);
    expect(find.text("Bar"), findsOneWidget);
  });
  testWidgets('SuggestionsPopup filters suggestions based on user input',
      (WidgetTester tester) async {
    // Define a mock onSelect function
    void mockOnSelect(String suggestion) {}

    // Build the SuggestionsPopup widget inside a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionsPopup(onSelect: mockOnSelect),
        ),
      ),
    );

    // Wait for any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Enter text into the search field to filter suggestions
    await tester.enterText(find.byType(TextField), 'cof');
    await tester.pumpAndSettle();

    // Verify the filtered suggestions
    expect(find.text("Coffee"), findsOneWidget);
    expect(find.text("Restaurant"), findsNothing);
    expect(find.text("Fast Food"), findsNothing);
    expect(find.text("Dessert"), findsNothing);
    expect(find.text("Shopping"), findsNothing);
    expect(find.text("Bar"), findsNothing);
  });
  testWidgets('SuggestionsPopup interacts with suggestion items',
      (WidgetTester tester) async {
    // Define a mock onSelect function
    String selectedSuggestion = '';
    void mockOnSelect(String suggestion) {
      selectedSuggestion = suggestion;
    }

    // Build the SuggestionsPopup widget inside a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionsPopup(onSelect: mockOnSelect),
        ),
      ),
    );

    // Wait for any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Tap on a suggestion item to select it
    await tester.tap(find.text("Restaurant"));
    await tester.pumpAndSettle();

    // Verify that the onSelect function is called with the correct suggestion
    expect(selectedSuggestion, "Restaurant");

    // Verify that the SuggestionsPopup is closed
    expect(find.byType(SuggestionsPopup), findsNothing);
  });
  testWidgets('SuggestionsPopup interacts with the "Use this Address" button',
      (WidgetTester tester) async {
    // Define a mock onSelect function
    String selectedSuggestion = '';
    void mockOnSelect(String suggestion) {
      selectedSuggestion = suggestion;
    }

    // Build the SuggestionsPopup widget inside a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionsPopup(onSelect: mockOnSelect),
        ),
      ),
    );

    // Wait for any asynchronous operations to complete
    await tester.pumpAndSettle();

    // Enter text into the search field
    await tester.enterText(find.byType(TextField), 'Custom Address');
    await tester.pumpAndSettle();

    // Tap on the "Use this Address" button
    await tester.tap(find.text("Use this Address"));
    await tester.pumpAndSettle();

    // Verify that the onSelect function is called with the correct suggestion
    expect(selectedSuggestion, "Custom Address");

    // Verify that the SuggestionsPopup is closed
    expect(find.byType(SuggestionsPopup), findsNothing);
  });
}
