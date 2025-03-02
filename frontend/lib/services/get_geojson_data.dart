import 'dart:convert';
import 'package:flutter/services.dart';

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
  final AssetBundle assetBundle;

  CampusService({AssetBundle? assetBundle})
      : assetBundle = assetBundle ?? rootBundle;

  Map<String, dynamic>? buildingBoundaries;
  Map<String, dynamic>? buildingList;
  Map<String, dynamic>? campusBoundaries;

  Future<void> loadGeoJsonData() async {
    try {
      // Load Building Boundaries
      String buildingBoundariesString = await assetBundle
          .loadString('assets/geojson/building_boundaries.geojson');
      buildingBoundaries = jsonDecode(buildingBoundariesString);

      // Load Building List
      String buildingListString =
          await assetBundle.loadString('assets/geojson/building_list.geojson');
      buildingList = jsonDecode(buildingListString);

      // Load Campus Boundaries
      String campusBoundariesString =
          await assetBundle.loadString('assets/geojson/campus.geojson');
      campusBoundaries = jsonDecode(campusBoundariesString);
    } catch (e) {
      print("Error loading GeoJSON files: $e");
    }
  }
  //Function to search for buildings
  List<String> searchBuildings(String query) {
    if (buildingList == null) return [];
    final buildings = List<String>.from(buildingList!.keys);
    return buildings.where((building) => building.toLowerCase().contains(query.toLowerCase())).toList();
  }
  //Function to get building names
  List<String> getBuildingNames() {
    List<String> buildingNames = [];
    if (buildingList != null) {
      buildingList!['features']?.forEach((building) {
        buildingNames.add(building['properties']['name']);
      });
    }
    return buildingNames;
  }

  Map<String, dynamic>? getBuildingBoundaries() {
    return buildingBoundaries;
  }

  Map<String, dynamic>? getBuildingList() {
    return buildingList;
  }

  Map<String, dynamic>? getCampusBoundaries() {
    return campusBoundaries;
  }
  
}
