import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/indoor_navigation_button.dart';



void main() {
  group('IndoorTrigger Widget Tests', () {
    testWidgets('renders correctly with proper styling', (WidgetTester tester) async {
      // Build the IndoorTrigger widget
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.red, 
          ),
          home: Scaffold(
            body: Center(
              child: IndoorTrigger(),
            ),
          ),
        ),
      );

      
      expect(find.byType(IndoorTrigger), findsOneWidget);
      

      expect(find.byType(Container), findsOneWidget);
      
      
      expect(find.byType(Icon), findsOneWidget);
      final Icon icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, equals(Icons.location_on));
      expect(icon.size, equals(30));
      expect(icon.color, equals(Colors.white));
      

      final Container container = tester.widget<Container>(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      

      expect(decoration.color, equals(Colors.red));
      

      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
      

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
      

      expect(container.padding, equals(const EdgeInsets.all(10)));
    });

    testWidgets('changes color with different theme', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primaryColor: Colors.blue, 
          ),
          home: Scaffold(
            body: Center(
              child: IndoorTrigger(),
            ),
          ),
        ),
      );

 
      final Container container = tester.widget<Container>(find.byType(Container));
      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.blue));
    });

    testWidgets('renders correctly with proper styling', (WidgetTester tester) async {

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(255, 0, 0, 1.0), 

      ),
      home: Scaffold(
        body: Center(
          child: IndoorTrigger(),
        ),
      ),
    ),
  );


  expect(find.byType(IndoorTrigger), findsOneWidget);
  
  
  expect(find.byType(Container), findsOneWidget);

  expect(find.byType(Icon), findsOneWidget);
  final Icon icon = tester.widget<Icon>(find.byType(Icon));
  expect(icon.icon, equals(Icons.location_on));
  expect(icon.size, equals(30));
  expect(icon.color, equals(Colors.white));
  

  final Container container = tester.widget<Container>(find.byType(Container));
  final BoxDecoration decoration = container.decoration as BoxDecoration;
  

  expect(decoration.color, equals(Colors.red.r)); 
  
  
  expect(decoration.borderRadius, equals(BorderRadius.circular(20)));

  expect(decoration.boxShadow, isNotNull);
  expect(decoration.boxShadow!.length, equals(1));
  

  expect(container.padding, equals(const EdgeInsets.all(10)));
});

testWidgets('changes color with different theme', (WidgetTester tester) async {
  // Build with a different theme color
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(0, 0, 255, 1.0), 
      ),
      home: Scaffold(
        body: Center(
          child: IndoorTrigger(),
        ),
      ),
    ),
  );


  final Container container = tester.widget<Container>(find.byType(Container));
  final BoxDecoration decoration = container.decoration as BoxDecoration;
  expect(decoration.color, equals(Colors.blue.b)); 
});

  });
}