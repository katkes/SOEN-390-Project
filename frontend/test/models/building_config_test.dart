import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:soen_390/models/building_config.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BuildingConfig', () {
    test('fromJson creates correct BuildingConfig instance', () {
      final json = {
        'displayName': 'Test Building',
        'mapId': 'test123',
        'keys': ['test', 'tb'],
        'floors': ['1', '2', '3'],
        'defaultFloor': '1',
        'roomPrefix': 'T',
        'rooms': ['101', '102', '103'],
      };

      final config = BuildingConfig.fromJson(json);

      expect(config.displayName, 'Test Building');
      expect(config.mapId, 'test123');
      expect(config.keys, ['test', 'tb']);
      expect(config.floors, ['1', '2', '3']);
      expect(config.defaultFloor, '1');
      expect(config.roomPrefix, 'T');
      expect(config.rooms, ['101', '102', '103']);
    });

    test('fromJson handles null floors and defaultFloor', () {
      final json = {
        'displayName': 'Test Building',
        'mapId': 'test123',
        'keys': ['test'],
        'roomPrefix': 'T',
        'rooms': ['101'],
      };

      final config = BuildingConfig.fromJson(json);

      expect(config.floors, null);
      expect(config.defaultFloor, null);
    });
  });

  group('BuildingConfigManager', () {
    setUp(() async {
      // Load the test configuration
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key = const StringCodec().decodeMessage(message) as String;
        if (key == 'assets/building_configs.json') {
          return ByteData.view(Uint8List.fromList(utf8.encode(
                  '{"buildings": {"hall": {"displayName": "Hall Building", "mapId": "test123", "keys": ["hall"], "floors": ["1"], "defaultFloor": "1", "roomPrefix": "H", "rooms": ["101"]}}}'))
              .buffer);
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('buildings loads configuration correctly', () async {
      final buildings = await BuildingConfigManager.buildings;

      expect(buildings.length, 1);
      expect(buildings['hall']?.displayName, 'Hall Building');
      expect(buildings['hall']?.mapId, 'test123');
    });

    test('findBuildingByRoom finds correct building', () async {
      final building = await BuildingConfigManager.findBuildingByRoom('H101');

      expect(building, isNotNull);
      expect(building?.displayName, 'Hall Building');
    });

    test('findBuildingByRoom returns null for non-existent room', () async {
      final building = await BuildingConfigManager.findBuildingByRoom('X999');

      expect(building, isNull);
    });

    test('findBuildingByName finds correct building', () async {
      final building = await BuildingConfigManager.findBuildingByName('hall');

      expect(building, isNotNull);
      expect(building?.displayName, 'Hall Building');
    });

    test('findBuildingByName returns null for non-existent building', () async {
      final building =
          await BuildingConfigManager.findBuildingByName('nonexistent');

      expect(building, isNull);
    });

    test('findBuildingByMapId finds correct building', () async {
      final building =
          await BuildingConfigManager.findBuildingByMapId('test123');

      expect(building, isNotNull);
      expect(building?.displayName, 'Hall Building');
    });

    test('findBuildingByMapId returns null for non-existent mapId', () async {
      final building =
          await BuildingConfigManager.findBuildingByMapId('nonexistent');

      expect(building, isNull);
    });

    test('getRoomNumber returns correct room number without prefix', () {
      expect(BuildingConfigManager.getRoomNumber('H101', 'H'), '101');
      expect(BuildingConfigManager.getRoomNumber('MB2.435', 'MB'), '2.435');
    });
  });
}
