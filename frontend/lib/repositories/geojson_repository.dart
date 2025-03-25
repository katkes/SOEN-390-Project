// geojson_repository.dart
import 'geojson_loader.dart';

class GeoJsonRepository {
  final GeoJsonLoader loader;

  GeoJsonRepository({GeoJsonLoader? loader})
      : loader = loader ?? GeoJsonLoader();

  Future<Map<String, dynamic>> loadBuildingList() =>
      loader.load('assets/geojson/building_list.geojson');

  Future<Map<String, dynamic>> loadBuildingBoundaries() =>
      loader.load('assets/geojson/building_boundaries.geojson');

  Future<Map<String, dynamic>> loadCampusBoundaries() =>
      loader.load('assets/geojson/campus.geojson');
}
