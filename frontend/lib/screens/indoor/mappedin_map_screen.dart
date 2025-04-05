/// A screen that displays an indoor navigation map using the Mappedin WebView.
///
/// Provides UI controls to trigger directions and floor selection via JS interop.
/// Uses a [GlobalKey] to interact with the underlying [MappedinWebView] state.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';

class MappedinMapScreen extends StatelessWidget {
  /// To allow injection of a custom webView (for testing)
  MappedinMapScreen({super.key, this.webView});

  /// Optionally injected WebView.
  final Widget? webView;

  /// GlobalKey to access the MappedinWebViewState.
  final GlobalKey<MappedinWebViewState> _webViewKey =
      GlobalKey<MappedinWebViewState>();

  /// Helper method to build Floating Action Buttons with standard styling.
  Widget _buildFABButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Indoor Navigation',
          // style: TextStyle(color: Colors.black),
        ),
        // backgroundColor: const Color(0xff912338),
        // iconTheme: const IconThemeData(color: Colors.white),
        iconTheme: const IconThemeData(),
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
          _buildFABButton("Set Floor", () async {
            await _webViewKey.currentState?.setFloor("Level 9");
          }),
        ],
      ),
    );
  }
}
