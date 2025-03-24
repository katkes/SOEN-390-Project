/// A screen that displays an indoor navigation map using the Mappedin WebView.
///
/// Provides UI controls to trigger directions and floor selection via JS interop.
/// Uses a [GlobalKey] to interact with the underlying [MappedinWebView] state.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';
import 'package:soen_390/screens/indoor_accessibility/indoor_accessibility_preference.dart';

class MappedinMapScreen extends StatelessWidget {
  /// To allow injection of a custom webView (for testing)
  MappedinMapScreen({super.key, this.webView});

  /// Key to access the [MappedinWebViewState] for calling methods like [showDirections] and [setFloor].
  final Widget? webView;

  /// GlobalKey to access the MappedinWebViewState.
  final GlobalKey<MappedinWebViewState> _webViewKey =
      GlobalKey<MappedinWebViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Navigation'),
        backgroundColor: const Color(0xff912338),
        actions: [
          // This button is now added so that tests can find it.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IndoorAccessibilityPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xff912338),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Specify Disability',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: webView ?? MappedinWebView(key: _webViewKey),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Triggers the `showDirections` method on the WebView with hardcoded IDs.
          /// This button mainly shows how to interact with the code.
          /// TODO: delete for the actual implementation, will be changed in 5.2.2
          ///
          /// - From location: `"124"`
          /// - To location: `"817"`
          /// - Accessible: true
          ElevatedButton(
            onPressed: () async {
              await _webViewKey.currentState
                  ?.showDirections("124", "Hrozzz", true);
            },
            child: const Text("Get Directions"),
          ),
          const SizedBox(height: 8),

          /// Triggers the `setFloor` method on the WebView.
          /// This button mainly shows how to interact with the code.
          /// TODO: delete for the actual implementation, will be changed in 5.2.2
          ///
          /// - Floor: `"Level 9"`
          ElevatedButton(
            onPressed: () async {
              await _webViewKey.currentState?.setFloor("Level 9");
            },
            child: const Text("Set Floor"),
          ),
        ],
      ),
    );
  }
}
