// geojson_repository.dart
import 'package:soen_390/utils/geojson_loader.dart';

class GeoJsonRepository {
  final GeoJsonLoader loader;

  GeoJsonRepository({GeoJsonLoader? loader})
      : loader = loader ?? GeoJsonLoader();

  Future<Map<String, dynamic>> loadBuildingList() =>
      loader.load('assets/geojson_files/building_list.geojson');

  Future<Map<String, dynamic>> loadBuildingBoundaries() =>
      loader.load('assets/geojson_files/building_boundaries.geojson');

  Future<Map<String, dynamic>> loadCampusBoundaries() =>
      loader.load('assets/geojson_files/campus.geojson');
}
