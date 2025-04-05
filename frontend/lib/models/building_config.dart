import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class BuildingConfig {
  final String displayName;
  final String mapId;
  final List<String> keys;
  final List<String>? floors;
  final String? defaultFloor;
  final String roomPrefix;
  final List<String> rooms;

  BuildingConfig({
    required this.displayName,
    required this.mapId,
    required this.keys,
    this.floors,
    this.defaultFloor,
    required this.roomPrefix,
    required this.rooms,
  });

  factory BuildingConfig.fromJson(Map<String, dynamic> json) {
    return BuildingConfig(
      displayName: json['displayName'],
      mapId: json['mapId'],
      keys: List<String>.from(json['keys']),
      floors: json['floors'] != null ? List<String>.from(json['floors']) : null,
      defaultFloor: json['defaultFloor'],
      roomPrefix: json['roomPrefix'],
      rooms: List<String>.from(json['rooms']),
    );
  }
}

class BuildingConfigManager {
  static Map<String, BuildingConfig>? _buildings;
  
  static Future<Map<String, BuildingConfig>> get buildings async {
    if (_buildings == null) {
      await _loadConfigs();
    }
    return _buildings!;
  }

  static Future<void> _loadConfigs() async {
    final jsonString = await rootBundle.loadString('assets/building_configs.json');
    final json = jsonDecode(jsonString);
    
    _buildings = {};
    (json['buildings'] as Map<String, dynamic>).forEach((key, value) {
      _buildings![key] = BuildingConfig.fromJson(value);
    });
  }

  /// Finds a building configuration by room number (e.g., "H907")
  static Future<BuildingConfig?> findBuildingByRoom(String roomNumber) async {
    final buildings = await BuildingConfigManager.buildings;
    
    for (final building in buildings.values) {
      if (roomNumber.startsWith(building.roomPrefix)) {
        final roomWithoutPrefix = roomNumber.substring(building.roomPrefix.length);
        if (building.rooms.contains(roomWithoutPrefix)) {
          return building;
        }
      }
    }
    return null;
  }

  /// Finds a building configuration by building name (e.g., "Hall")
  static Future<BuildingConfig?> findBuildingByName(String buildingName) async {
    final buildings = await BuildingConfigManager.buildings;
    for (final building in buildings.values) {
      if (building.keys.contains(buildingName.toLowerCase())) {
        return building;
      }
    }
    return null;
  }

  /// Finds a building configuration by map ID
  /// Returns null if the building is not found or if there's an error
  static Future<BuildingConfig?> findBuildingByMapId(String mapId) async {
    try {
      if (mapId.isEmpty) {
        debugPrint('Error: Empty map ID provided');
        return null;
      }

      final buildings = await BuildingConfigManager.buildings;
      
      // Check if the map ID exists in any building
      for (final building in buildings.values) {
        if (building.mapId == mapId) {
          return building;
        }
      }
      
      debugPrint('Error: No building found with map ID: $mapId');
      return null;
    } catch (e) {
      debugPrint('Error finding building by map ID: $e');
      return null;
    }
  }

  /// Gets the room number without the building prefix
  static String getRoomNumber(String fullRoomNumber, String roomPrefix) {
    return fullRoomNumber.substring(roomPrefix.length);
  }
} 
