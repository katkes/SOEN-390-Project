// File: test/mappedin_map_controller_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';
import 'package:soen_390/widgets/mappedin_webview.dart';

@GenerateMocks([MappedinWebViewState])
import 'mappedin_map_controller_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Override the asset bundle for building config JSON.
  const testJson = '''
  {
    "buildings": {
      "building1": {
        "displayName": "Test Building",
        "mapId": "test-map-id",
        "keys": ["test building"],
        "floors": ["1", "2"],
        "defaultFloor": "1",
        "roomPrefix": "H",
        "rooms": ["907", "908"]
      }
    }
  }
  ''';

  final ByteData testData =
      ByteData.view(Uint8List.fromList(utf8.encode(testJson)).buffer);

  // Set a mock message handler for asset loading.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
    final String key = const StringCodec().decodeMessage(message) as String;
    if (key == 'assets/building_configs.json') {
      return testData;
    }
    return null;
  });

  late MappedinMapController controller;
  late MockMappedinWebViewState mockWebViewState;

  setUp(() {
    controller = MappedinMapController();
    mockWebViewState = MockMappedinWebViewState();
    // Inject our mock web view state into the controller using a fake GlobalKey.
    controller.webViewKey = FakeGlobalKey(mockWebViewState);

    // Add stub for waitForMapLoaded
    when(mockWebViewState.waitForMapLoaded()).thenAnswer((_) async => true);
  });

  group('MappedinMapController', () {
    test('initial state', () {
      expect(controller.currentMapId, isNull);
      expect(controller.currentBuilding, isNull);
    });

    group('selectBuildingByName', () {
      test('successful building selection', () async {
        // Using the real BuildingConfigManager, "Test Building" should be found.
        final result = await controller.selectBuildingByName('Test Building');
        expect(result, isTrue);
        expect(controller.currentMapId, 'test-map-id');
      });

      test('building not found', () async {
        final result =
            await controller.selectBuildingByName('Non-existent Building');
        expect(result, isFalse);
        expect(controller.currentMapId, isNull);
      });
    });

    group('selectBuildingById', () {
      test('successful map ID selection', () async {
        final result = await controller.selectBuildingById('another-map-id');
        expect(result, isTrue);
        expect(controller.currentMapId, 'another-map-id');
      });
    });

    group('setMapId', () {
      test('sets map ID', () {
        final result = controller.setMapId('set-map-id');
        expect(result, isTrue);
        expect(controller.currentMapId, 'set-map-id');
      });
    });

    group('navigateToRoom', () {
      test('successful room navigation', () async {
        final result = await controller.navigateToRoom('H907');
        expect(result, isTrue);
        expect(controller.currentMapId, 'test-map-id');
        expect(controller.currentBuilding, isNotNull);
        expect(controller.currentBuilding?.displayName, 'Test Building');

        // Verify the actual calls being made
        verify(mockWebViewState.reloadWithMapId('test-map-id')).called(1);
        verify(mockWebViewState.waitForMapLoaded()).called(1);
        verify(mockWebViewState.navigateToRoom('907')).called(1);
      });

      test('building not found for room', () async {
        // Room "X123" does not match the test building's roomPrefix ("H").
        final result = await controller.navigateToRoom('X123');
        expect(result, isFalse);
        expect(controller.currentMapId, isNull);
        expect(controller.currentBuilding, isNull);
      });

      test('failed navigation due to exception', () async {
        // Simulate an exception in the WebView state.
        when(mockWebViewState.navigateToRoom(any))
            .thenThrow(Exception('Navigation error'));

        final result = await controller.navigateToRoom('H907');
        expect(result, isFalse);
      });
    });
  });
}

class FakeGlobalKey implements GlobalKey<MappedinWebViewState> {
  final MappedinWebViewState fakeState;

  FakeGlobalKey(this.fakeState);

  @override
  MappedinWebViewState? get currentState => fakeState;

  @override
  Widget? get currentWidget => null;

  @override
  BuildContext? get currentContext => null;
}
