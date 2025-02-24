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

    // Checks if the onChanged callback is called when the text changes.
    testWidgets('calls onChanged callback when text changes',
        (WidgetTester tester) async {
      String changedValue = '';
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              controller: controller,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();

      const testText = 'Flutter Testing';
      await tester.enterText(find.byType(TextField), testText);
      await tester.pumpAndSettle();

      expect(changedValue, equals(testText));
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
  });
}
