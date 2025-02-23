// made the test for the main.dart file
// checks if the app builds without crashing
// if the app builds without crashing, the test passes
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/main.dart';

void main() {
  testWidgets('MyApp builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
