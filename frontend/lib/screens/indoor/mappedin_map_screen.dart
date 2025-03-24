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

  /// Optionally injected WebView.
  final Widget? webView;

  /// GlobalKey to access the MappedinWebViewState.
  final GlobalKey<MappedinWebViewState> _webViewKey =
      GlobalKey<MappedinWebViewState>();

  /// Helper method for building the AppBar's action button.
  Widget _buildAppBarButton(BuildContext context) {
    return Padding(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

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
        backgroundColor: const Color(0xff912338),
        actions: [
          _buildAppBarButton(context),
        ],
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
