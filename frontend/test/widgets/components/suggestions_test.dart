// This file contains widget tests for the SuggestionsPopup widget.
// The tests verify that the SuggestionsPopup widget correctly displays the suggestions,
// filters suggestions based on user input, and interacts with the close button and suggestion items as expected.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/suggestions.dart';

void main() {
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
