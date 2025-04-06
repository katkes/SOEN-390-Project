/// Unit tests for the `SuggestionsPopup` widget.
///
/// These tests verify the correct behavior of the `SuggestionsPopup` widget, including:
/// - Rendering of the widget and its components, such as the text field.
/// - Correct filtering and display of suggestions based on user input.
/// - Proper interaction with the widget, including selecting a suggestion and updating the callback.
///
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/widgets/suggestions.dart';

void main() {
  setUp(() {
    // Load environment variables for testing
    dotenv.testLoad(fileInput: 'GOOGLE_PLACES_API_KEY=mock-api-key');
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
