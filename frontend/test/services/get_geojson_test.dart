import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/services.dart';
import 'package:soen_390/services/get_geojson_data.dart';

import 'get_geojson_test.mocks.dart';

@GenerateMocks([AssetBundle])
void main() {
  group('CampusService Tests', () {
    late MockAssetBundle mockAssetBundle;
    late CampusService campusService;

    setUp(() {
      mockAssetBundle = MockAssetBundle();

      campusService = CampusService(assetBundle: mockAssetBundle);
    });

    test('should load and parse GeoJSON data successfully', () async {
      const mockGeoJson = '{"type": "FeatureCollection", "features": []}';

      when(mockAssetBundle
              .loadString('assets/geojson/building_boundaries.geojson'))
          .thenAnswer((_) async => mockGeoJson);
      when(mockAssetBundle.loadString('assets/geojson/building_list.geojson'))
          .thenAnswer((_) async => mockGeoJson);
      when(mockAssetBundle.loadString('assets/geojson/campus.geojson'))
          .thenAnswer((_) async => mockGeoJson);

      await campusService.loadGeoJsonData();

      expect(campusService.getBuildingBoundaries(), isNotNull);
      expect(campusService.getBuildingList(), isNotNull);
      expect(campusService.getCampusBoundaries(), isNotNull);
    });

    test('should return null when loadString fails', () async {
      // Mock throwing exceptions
      when(mockAssetBundle.loadString(any))
          .thenThrow(PlatformException(code: '404', message: 'File not found'));

      await campusService.loadGeoJsonData();

      // Check that the values are null after the failure
      expect(campusService.getBuildingBoundaries(), isNull);
      expect(campusService.getBuildingList(), isNull);
      expect(campusService.getCampusBoundaries(), isNull);
    });
  });
}
