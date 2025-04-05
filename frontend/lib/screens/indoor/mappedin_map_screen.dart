///
/// Provides UI controls to trigger directions and floor selection via JS interop.
/// Uses a [GlobalKey] to interact with the underlying [MappedinWebView] state.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';

class MappedinMapScreen extends StatefulWidget {
  /// To allow injection of a custom webView (for testing)
  MappedinMapScreen({
    super.key,
    this.webView,
    this.controller,
  });

  /// Optionally injected WebView.
  final Widget? webView;

  /// Optional controller for managing the map state
  final MappedinMapController? controller;

  @override
  State<MappedinMapScreen> createState() => _MappedinMapScreenState();
}

class _MappedinMapScreenState extends State<MappedinMapScreen> {
  late final MappedinMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MappedinMapController();
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
        title: const Text(
          'Indoor Navigation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff912338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: MappedinWebView(
        key: _controller.webViewKey,
        mapId: _controller.currentMapId,
      ),
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
              await _controller.webViewKey.currentState
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
          _buildFABButton("Navigate to H813 from Outside", () async {
            await _controller.webViewKey.currentState?.navigateToRoom("813");
          }),
        ],
      ),
    );
  }
}
