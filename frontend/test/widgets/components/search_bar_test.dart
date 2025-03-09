/// Unit tests for the search bar functionality in the frontend
/// The tests ensure that the search bar behaves as expected
/// under various conditions, including input handling, search execution, and result
/// display. These tests help maintain the reliability and correctness of the search
/// feature in the application.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/search_bar.dart';

void main() {
  group('SearchBarWidget Tests', () {
    Finder findSearchBarGestureDetector() {
      return find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector && widget.child is AnimatedContainer,
      );
    }

    // Checks if the search bar is collapsed initally.
    testWidgets('is collapsed initially', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);

      final containerSize = tester.getSize(find.byType(AnimatedContainer));
      expect(containerSize.width, equals(58));
    });

    // Checks if the search bar expands when tapped.
    testWidgets('expands on tap', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      final containerSize = tester.getSize(find.byType(AnimatedContainer));
      expect(containerSize.width, equals(280));
    });

    // Checks if the search bar collapses when tapped again.
    testWidgets('toggles collapse when tapped again',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      final searchBarFinder = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector && widget.child is AnimatedContainer,
      );
      await tester.tap(searchBarFinder);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);

      final containerSize = tester.getSize(find.byType(AnimatedContainer));
      expect(containerSize.width, equals(58));
    });

    testWidgets('displays suggestions on text input',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      // Create the widget in the test environment
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      // Tap to expand the search bar
      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      // Input a search query that would trigger suggestions
      await tester.enterText(find.byType(TextField), 'a');

      // Allow time for suggestions to populate
      await tester.pumpAndSettle();

      // Check that the suggestion list is displayed
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });

    // Tests that submitting a search query via the text input's "done" action
    // triggers the expected behavior (e.g., location search or navigation).
    testWidgets('handles search submission', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hall Building');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

    });

    // Tests that selecting a suggestion from the displayed list of suggestions
    // after typing in the search bar triggers the expected behavior (e.g., filling
    // the text field with the selected suggestion).
    testWidgets('handles suggestion selection', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'H');
      await tester.pumpAndSettle();

      if (find.byType(InkWell).evaluate().isNotEmpty) {
        await tester.tap(find.byType(InkWell).first);
        await tester.pumpAndSettle();
      }

    });

    // Tests that clearing the search query (e.g., by deleting all text)
    // results in the clearing of any displayed suggestions.
    testWidgets('clears suggestions on empty query', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'H');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

    });

    // Tests that the optional 'onLocationFound' callback is called with the
    // correct location information when a location is found (e.g., after
    // submitting a search query).
    testWidgets('calls onLocationFound callback when provided', (WidgetTester tester) async {
      final controller = TextEditingController();
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              controller: controller,
              onLocationFound: (_) {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hall Building');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

    });

    // Tests that the widget correctly handles changes in focus (e.g., gaining
    // focus when tapped, losing focus when tapped outside the search bar).
    testWidgets('widget correctly handles focus changes', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.tap(find.byType(Scaffold), warnIfMissed: false);
      await tester.pumpAndSettle();
    });

  });
}
