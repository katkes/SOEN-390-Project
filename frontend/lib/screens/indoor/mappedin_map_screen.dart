/*
 *
 * This screen loads a local HTML file (assets/mappedin.html) that embeds a Mappedin map.
 * The HTML is loaded using rootBundle and then displayed in an InAppWebView.
 * WebView settings enable JavaScript and useHybridComposition (for Android).
 */

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';

class MappedinMapScreen extends StatelessWidget {
  MappedinMapScreen({super.key});

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
          ElevatedButton(
            onPressed: () async {
              await _webViewKey.currentState?.showDirections("124", "817");
            },
            child: const Text("Get Directions"),
          ),
          const SizedBox(height: 8),
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
