/// A screen that displays an indoor navigation map using the Mappedin WebView.
///
/// Provides UI controls to trigger directions and floor selection via JS interop.
/// Uses a [GlobalKey] to interact with the underlying [MappedinWebView] state.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';

class MappedinMapScreen extends StatefulWidget {
  /// To allow injection of a custom webView (for testing)
  const MappedinMapScreen({super.key, this.webView});

  /// Optionally injected WebView.
  final Widget? webView;

  @override
  State<MappedinMapScreen> createState() => _MappedinMapScreenState();
}

class _MappedinMapScreenState extends State<MappedinMapScreen> {
  final GlobalKey<MappedinWebViewState> _webViewKey =
      GlobalKey<MappedinWebViewState>();
  String? _selectedBuilding;

  /// List of available building names and corresponding map IDs
  final Map<String, String> buildingMapIds = {
    "Hall Building": "67968294965a13000bcdfe74",
    "JMSB": "67e1ac8eaa7c59000baf8dcf",
    "Library Building": "67ba2570a39568000bc4b334",
    "SP Building": "LOYO_MAP_ID_1",
    "CC Building": "LOYO_MAP_ID_2",
  };

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
        actions: [
          /// Dropdown to switch buildings by map ID
          DropdownButton<String>(
            hint: const Text("Select Building",
                style: TextStyle(color: Colors.white)),
            value: _selectedBuilding,
            dropdownColor: Colors.black,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            iconEnabledColor: Colors.white,
            onChanged: (String? buildingName) async {
              if (buildingName != null) {
                setState(() => _selectedBuilding = buildingName);
                final mapId = buildingMapIds[buildingName]!;
                await _webViewKey.currentState?.reloadWithMapId(mapId);
              }
            },
            items: buildingMapIds.keys.map((name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }).toList(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: widget.webView ?? MappedinWebView(key: _webViewKey),
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
