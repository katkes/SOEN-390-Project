import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soen_390/screens/indoor/mappedin_map_screen.dart';
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
      controller: FakeMappedinMapController(),
    );
  }
}

void main() {
  testWidgets('displays AppBar title and buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestMappedinMapScreen()));

    expect(find.text('Indoor Navigation'), findsOneWidget);
  });

  testWidgets('selecting from dropdown changes building map ID',
      (tester) async {
    final fakeController = FakeMappedinMapController();

    await tester.pumpWidget(MaterialApp(
      home: MappedinMapScreen(
        controller: fakeController,
        webView: const FakeMappedinWebView(),
      ),
    ));

    // Open the dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    // Select "JMSB"
    await tester.tap(find.text('JMSB').last);
    await tester.pumpAndSettle();

    // Check if the controller received the correct mapId
    expect(fakeController.selectedMapId, equals("67e1ac8eaa7c59000baf8dcf"));
  });
}
