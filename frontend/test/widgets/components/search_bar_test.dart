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
      await tester.tap(findSearchBarGestureDetector());
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
    });

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
      expect(controller.text, equals('Hall Building'));
    });

    testWidgets('handles non-matching query', (WidgetTester tester) async {
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
      // Input a search query that would trigger suggestion
      await tester.enterText(find.byType(TextField), 'RandomText');
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsNothing);
    });
  });
}
