import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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

  /// Gets the room number without the building prefix
  static String getRoomNumber(String fullRoomNumber, String roomPrefix) {
    return fullRoomNumber.substring(roomPrefix.length);
  }
} 