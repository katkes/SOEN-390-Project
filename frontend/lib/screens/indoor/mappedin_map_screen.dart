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
        title: const Text('Indoor Navigation'),
        backgroundColor: const Color(0xff912338)
      ),
      body: webView ?? MappedinWebView(key: _webViewKey),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFABButton("Get Directions", () async {
            await _webViewKey.currentState
                ?.showDirections("124", "Hrozzz", true);
          }),
          const SizedBox(height: 8),
          _buildFABButton("Set Floor", () async {
            await _webViewKey.currentState?.setFloor("Level 9");
          }),
        ],
      ),
    );
  }
}
