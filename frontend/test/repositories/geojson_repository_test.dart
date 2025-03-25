import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soen_390/utils/geojson_loader.dart';
import 'package:soen_390/repositories/geojson_repository.dart';

@GenerateMocks([GeoJsonLoader])
import 'geojson_repository_test.mocks.dart';

void main() {
  group('GeoJsonRepository', () {
    late MockGeoJsonLoader mockLoader;
    late GeoJsonRepository repository;

    setUp(() {
      mockLoader = MockGeoJsonLoader();
      repository = GeoJsonRepository(loader: mockLoader);
    });

    final mockData = {'type': 'FeatureCollection', 'features': []};

    test('loadBuildingList returns data from loader', () async {
      when(mockLoader.load('assets/geojson_files/building_list.geojson'))
          .thenAnswer((_) async => mockData);

      final result = await repository.loadBuildingList();

      expect(result, mockData);
      verify(mockLoader.load('assets/geojson_files/building_list.geojson'))
          .called(1);
    });

    test('loadBuildingBoundaries returns data from loader', () async {
      when(mockLoader.load('assets/geojson_files/building_boundaries.geojson'))
          .thenAnswer((_) async => mockData);

      final result = await repository.loadBuildingBoundaries();

      expect(result, mockData);
      verify(mockLoader
              .load('assets/geojson_files/building_boundaries.geojson'))
          .called(1);
    });

    test('loadCampusBoundaries returns data from loader', () async {
      when(mockLoader.load('assets/geojson_files/campus.geojson'))
          .thenAnswer((_) async => mockData);

      final result = await repository.loadCampusBoundaries();

      expect(result, mockData);
      verify(mockLoader.load('assets/geojson_files/campus.geojson')).called(1);
    });
  });
}
