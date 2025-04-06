/// This file contains the controller logic for managing the Mappedin indoor mapping functionality.
/// It provides a centralized controller class that handles building selection, map navigation,
/// and room finding features within the Mappedin WebView integration.
///
/// The MappedinMapController class manages the state of the map view and provides methods
/// for interacting with the Mappedin SDK through a WebView interface.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';
import 'package:soen_390/models/building_config.dart';

/// Controller class to manage the Mappedin map state and building selection
class MappedinMapController {
  GlobalKey<MappedinWebViewState> webViewKey =
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
      final building =
          await BuildingConfigManager.findBuildingByName(buildingName);
      debugPrint('Building found: ${building?.mapId}');

      if (building == null) {
        debugPrint('Building not found: $buildingName');
        return false;
      }

      return selectBuildingById(building.mapId);
    } catch (e) {
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
      await webViewKey.currentState?.reloadWithMapId(mapId);
      return true;
    } catch (e) {
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

      // Get the room number without the building prefix
      final roomWithoutPrefix =
          BuildingConfigManager.getRoomNumber(roomNumber, building.roomPrefix);

      // Show directions to the room
      await webViewKey.currentState?.navigateToRoom(roomWithoutPrefix);

      debugPrint('Navigated to room: $roomWithoutPrefix');

      return true;
    } catch (e) {
      debugPrint('Error navigating to room: $e');
      return false;
    }
  }
}
