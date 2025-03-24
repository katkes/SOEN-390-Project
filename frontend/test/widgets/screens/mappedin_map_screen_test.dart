import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/indoor/mappedin_map_screen.dart';
import 'package:soen_390/screens/indoor_accessibility/indoor_accessibility_preference.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';
import 'fake_mappedin_webview.dart';

class TestMappedinMapScreen extends StatelessWidget {
  const TestMappedinMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a GlobalKey for accessing the state of the fake.
    final testKey = GlobalKey<MappedinWebViewState>();
    return MappedinMapScreen(
      webView: FakeMappedinWebView(key: testKey),
    );
  }
}

void main() {
  testWidgets('displays AppBar title and buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestMappedinMapScreen()));

    expect(find.text('Indoor Navigation'), findsOneWidget);
    expect(find.text('Get Directions'), findsOneWidget);
    expect(find.text('Set Floor'), findsOneWidget);
  });

  testWidgets(
      'navigates to IndoorAccessibilityPage when disability button is pressed',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestMappedinMapScreen()));

    // Tap the "Specify Disability" button.
    await tester.tap(find.text('Specify Disability'));
    await tester.pumpAndSettle();

    // Verify that navigation occurred.
    expect(find.byType(IndoorAccessibilityPage), findsOneWidget);
  });
}
