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

  /// Optional controller for managing the map state both for testing and if there's no need to modify it.
  /// If just opening mappedin screen by default, you don't need to update the controller's defaults.
  final MappedinMapController? controller;

  @override
  State<MappedinMapScreen> createState() => _MappedinMapScreenState();
}

class _MappedinMapScreenState extends State<MappedinMapScreen> {
  late final MappedinMapController _controller;
  String? _selectedBuilding;

  /// List of available building names and corresponding map IDs
  final Map<String, String> buildingMapIds = {
    "Hall Building": "67968294965a13000bcdfe74",
    "JMSB": "67e1ac8eaa7c59000baf8dcf",
    "Library Building": "67ba2570a39568000bc4b334",
  };

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MappedinMapController();
    _selectedBuilding = "Hall Building";
    final defaultMapId = buildingMapIds[_selectedBuilding]!;
    _controller.selectBuildingById(defaultMapId);
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
        title: const Text('Indoor Navigation',
            style: TextStyle(color: Colors.white)),
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
                await _controller.selectBuildingById(mapId);
                setState(() {}); // Force rebuild to refresh map
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
      body: widget.webView ??
          MappedinWebView(
            key: _controller.webViewKey,
            mapId: _controller.currentMapId,
          ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Triggers the `navigateToRoom` method on the WebView.
          /// This button mainly shows how to interact with the code.
          /// TODO: delete for the actual implementation, will be changed in 7.1.2
          /// It is here for testing purposes.
          _buildFABButton("Navigate to H813 from Outside", () async {
            await _controller.webViewKey.currentState?.navigateToRoom("813");
          }),
        ],
      ),
    );
  }
}
