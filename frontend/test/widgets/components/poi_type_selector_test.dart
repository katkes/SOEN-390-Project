import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/widgets/poi_type_selector.dart';

void main() {
  testWidgets('Renders default POI types', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: POITypeSelector(onTypeSelected: (_) {}),
      ),
    ));

    // Check if a few default types render as buttons
    expect(find.text('RESTAURANT'), findsOneWidget);
    expect(find.text('STORE'), findsOneWidget);
    expect(find.text('TOURIST ATTRACTION'), findsOneWidget);

    // Ensure multiple buttons are rendered (default types length is 14)
    final buttons = find.byType(ElevatedButton);
    expect(buttons, findsNWidgets(14));
  });

  testWidgets('Renders custom POI types', (WidgetTester tester) async {
    final customTypes = ['gym', 'cafe', 'library'];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: POITypeSelector(
          types: customTypes,
          onTypeSelected: (_) {},
        ),
      ),
    ));

    // Verify custom types rendered
    expect(find.text('GYM'), findsOneWidget);
    expect(find.text('CAFE'), findsOneWidget);
    expect(find.text('LIBRARY'), findsOneWidget);

    final buttons = find.byType(ElevatedButton);
    expect(buttons, findsNWidgets(3));
  });

  testWidgets('Selecting a type triggers callback with correct value',
      (WidgetTester tester) async {
    String? selectedType;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: POITypeSelector(
          types: ['museum', 'theater'],
          onTypeSelected: (type) {
            selectedType = type;
          },
        ),
      ),
    ));

    // Tap the "MUSEUM" button
    await tester.tap(find.text('MUSEUM'));
    await tester.pump();

    expect(selectedType, 'museum');

    // Tap the "THEATER" button
    await tester.tap(find.text('THEATER'));
    await tester.pump();

    expect(selectedType, 'theater');
  });
}
