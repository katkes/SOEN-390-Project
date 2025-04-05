///
/// Provides UI controls to trigger directions and floor selection via JS interop.
/// Uses a [GlobalKey] to interact with the underlying [MappedinWebView] state.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';
import 'package:soen_390/models/building_config.dart';

/// Controller class to manage the Mappedin map state and building selection
class MappedinMapController {
  final GlobalKey<MappedinWebViewState> webViewKey =
      GlobalKey<MappedinWebViewState>();
  String? _currentMapId;
  BuildingConfig? _currentBuilding;

  /// The current map ID being displayed
  String? get currentMapId => _currentMapId;

  /// The current building being displayed
  BuildingConfig? get currentBuilding => _currentBuilding;

  /// Changes the current building map being displayed by building name
  ///
  /// [buildingName] - The name of the building to switch to
  /// Returns true if the building was found and switch was successful
  Future<bool> selectBuildingByName(String buildingName) async {
    try {
      debugPrint('Switching building: $buildingName');
      final building = await BuildingConfigManager.findBuildingByName(buildingName);
      debugPrint('Building found: ${building?.mapId}');
      
      if (building == null) {
        debugPrint('Building not found: $buildingName');
        return false;
      }

      return selectBuildingById(building.mapId);
    } catch (e) {
      debugPrint('Error switching building: $e');
      return false;
    }
  }

  /// Changes the current building map being displayed
  ///
  /// [mapId] - The new map ID to display
  /// Returns true if the map was successfully changed
  Future<bool> selectBuildingById(String mapId) async {
    try {
      _currentMapId = mapId;
      // Reload the WebView with the new map ID
      // await webViewKey.currentState?.reloadWithMapId(mapId);
      return true;
    } catch (e) {
      debugPrint('Error switching building: $e');
      return false;
    }
  }

  bool setMapId(String mapId) {
    _currentMapId = mapId;
    return true;
    // TODO check if map id is valid
  }

  /// Navigates to a specific room in a building
  ///
  /// [roomNumber] - The full room number including building prefix (e.g., "H907")
  /// Returns true if navigation was successful
  Future<bool> navigateToRoom(String roomNumber) async {
    try {
      final building =
          await BuildingConfigManager.findBuildingByRoom(roomNumber);
      if (building == null) {
        debugPrint('Building not found for room: $roomNumber');
        return false;
      }

      // Switch to the building's map if we're not already there
      if (_currentMapId != building.mapId) {
        final success = await selectBuildingById(building.mapId);
        if (!success) return false;
      }

      _currentBuilding = building;
      _currentMapId = building.mapId;

      // Navigate to the room
      await webViewKey.currentState?.navigateToRoom(roomNumber);

      // TODO: Add camera movement to the room location
      // This will require additional JavaScript functions in mappedin.js
      // to handle camera positioning to specific rooms

      return true;
    } catch (e) {
      debugPrint('Error navigating to room: $e');
      return false;
    }
  }
}

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
          _buildFABButton("Set Room", () async {
            await _controller.webViewKey.currentState?.navigateToRoom("813");
          }),
        ],
      ),
    );
  }
