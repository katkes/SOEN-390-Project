import 'package:soen_390/repositories/geojson_repository.dart';

/// Service for loading and managing campus GeoJSON data.
///
/// This service handles the loading and caching of GeoJSON files containing:
/// * Building boundaries
/// * Building list
/// * Campus boundaries
///
/// Example usage:
/// ```dart
/// final campusService = CampusService();
/// await campusService.loadGeoJsonData();
/// final buildings = campusService.getBuildingList();
/// ```
class CampusService {
  final GeoJsonRepository repository;

  CampusService({GeoJsonRepository? repository})
      : repository = repository ?? GeoJsonRepository();

  Map<String, dynamic>? buildingBoundaries;
  Map<String, dynamic>? buildingList;
  Map<String, dynamic>? campusBoundaries;

  Future<void> loadGeoJsonData() async {
    try {
      buildingBoundaries = await repository.loadBuildingBoundaries();
    } catch (e) {
      print("Error loading building boundaries: $e");
    }

    try {
      buildingList = await repository.loadBuildingList();
    } catch (e) {
      print("Error loading building list: $e");
    }

    try {
      campusBoundaries = await repository.loadCampusBoundaries();
    } catch (e) {
      print("Error loading campus boundaries: $e");
    }
  }
}
