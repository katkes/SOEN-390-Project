// Test File: suggestions_test.dart
// This group of tests verifies that the SuggestionsPopup widget correctly displays all suggestions and calls the onSelect callback when a suggestion is tapped.
// The tests should pass as the SuggestionsPopup widget should display all suggestions and call the onSelect callback when a suggestion is tapped.

library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/suggestions.dart';

void main() {
  // This group of tests verifies that the SuggestionsPopup widget correctly displays all suggestions and calls the onSelect callback when a suggestion is tapped.
  testWidgets('SuggestionsPopup builds without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SuggestionsPopup(onSelect: (String value) {}),
    ));
    expect(find.byType(Dialog), findsOneWidget);
  });

  // This test verifies that the SuggestionsPopup widget correctly displays all suggestions.
  testWidgets('SuggestionsPopup displays all suggestions',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SuggestionsPopup(onSelect: (String value) {}),
    ));
    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Fast Food'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Dessert'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Bar'), findsOneWidget);
  });

  testWidgets('SuggestionsPopup calls onSelect when a suggestion is tapped',
      (WidgetTester tester) async {
    String selectedValue = '';
    await tester.pumpWidget(MaterialApp(
      home: SuggestionsPopup(onSelect: (String value) {
        selectedValue = value;
      }),
    ));

    await tester.tap(find.text('Restaurant'));
    await tester.pumpAndSettle();
    expect(selectedValue, 'Restaurant');
  });
}
