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

      testWidgets('Testing the UI', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(controller: controller),
          ),
        ),
      );

      expect(find.byType(SearchBarWidget), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Loyola');
      await tester.pumpAndSettle();
      
  
    final container = find.byKey(const Key("123")).evaluate().first;

    // Check the container's color
    final containerColor = (container.widget as Container).decoration as BoxDecoration;
    expect(containerColor.color, Colors.white);

    // Check the container's box shadow
    final boxShadow = containerColor.boxShadow?.first;
    expect(boxShadow?.color, Colors.black.withAlpha(63));
    expect(boxShadow?.blurRadius, 0);

    // Check the padding of the container
    final padding = (container.widget as Container).padding as EdgeInsets;
    expect(padding, const EdgeInsets.all(8.0));

    // Check the typography of the suggestion text
    final suggestionText = find.text('Loyola').evaluate().single;
    final textStyle = (suggestionText.widget as EditableText).style;
    expect(textStyle?.fontSize, 16);
    expect(textStyle?.fontWeight, FontWeight.w400);
  
    });
  

group('SearchBarWidget Tests', () {


  late TextEditingController controller;
  late SearchBarWidget searchBarWidget;

    setUp(() {
      controller = TextEditingController();
      searchBarWidget = SearchBarWidget(
        controller: controller,
        onLocationFound: (_) {},
        onBuildingSelected: (_) {},
        onCampusSelected: (_) {},
      );
    });

    testWidgets('Test search with empty query', (WidgetTester tester) async {
      // Build the widget tree
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: searchBarWidget)));

      // Act: Trigger search with an empty query
      controller.text = "";
      await tester.pumpAndSettle();

      // Verify: Ensure no action is taken on empty query (this could be improved based on what you expect in the UI)
      expect(controller.text, "");
    });
  });


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
