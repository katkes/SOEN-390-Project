import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/indoor_navigation_button.dart';

void main() {
  group('IndoorNavigationButton Widget Tests', () {
    testWidgets('renders correctly with default styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColor: Colors.red),
          home: const Scaffold(body: Center(child: IndoorNavigationButton())),
        ),
      );

      expect(find.byType(IndoorNavigationButton), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);

      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, equals(Icons.location_on));
      expect(icon.size, equals(30));
      expect(icon.color, equals(Colors.white));

      final Container container =
          tester.widget<Container>(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      expect(decoration.color, equals(Colors.red)); // Fix: Correct color check
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
      expect(container.padding, equals(const EdgeInsets.all(10)));
    });

    testWidgets('changes color with different theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColor: Colors.blue),
          home: const Scaffold(body: Center(child: IndoorNavigationButton())),
        ),
      );

      final Container container =
          tester.widget<Container>(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.blue)); // Fix: Correct color check
    });

    testWidgets('renders correctly with RGBA color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
              primaryColor: const Color.fromRGBO(255, 0, 0, 1.0)), // Fully red
          home: const Scaffold(body: Center(child: IndoorNavigationButton())),
        ),
      );

      final Container container =
          tester.widget<Container>(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color,
          equals(const Color(0xFFFF0000))); // Fix: Correct color check
    });

    testWidgets('changes color with different RGBA theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
              primaryColor: const Color.fromRGBO(0, 0, 255, 1.0)), // Fully blue
          home: const Scaffold(body: Center(child: IndoorNavigationButton())),
        ),
      );

      final Container container =
          tester.widget<Container>(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color,
          equals(const Color(0xFF0000FF))); // Fix: Correct color check
    });
  });
}
