/// A screen that displays an indoor navigation map using the Mappedin WebView.
///
/// Provides UI controls to trigger directions and floor selection via JS interop.
/// Uses a [GlobalKey] to interact with the underlying [MappedinWebView] state.

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';

class MappedinMapScreen extends StatelessWidget {
  /// Constructs the [MappedinMapScreen].
  MappedinMapScreen({super.key});

  /// Key to access the [MappedinWebViewState] for calling methods like [showDirections] and [setFloor].
  final GlobalKey<MappedinWebViewState> _webViewKey =
      GlobalKey<MappedinWebViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Navigation'),
        backgroundColor: const Color(0xff912338),
      ),
      body: MappedinWebView(key: _webViewKey),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Triggers the `showDirections` method on the WebView with hardcoded IDs.
          /// This button mainly shows how to interact with the codo. TODO delete for the actual
          /// implementation
          ///
          /// - From location: `"124"`
          /// - To location: `"817"`
          ElevatedButton(
            onPressed: () async {
              await _webViewKey.currentState?.showDirections("124", "817");
            },
            child: const Text("Get Directions"),
          ),

          const SizedBox(height: 8),

          /// Triggers the `setFloor` method on the WebView.
          /// This button mainly shows how to interact with the codo. TODO delete for the actual
          /// implementation
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

