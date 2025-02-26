import 'dart:convert';
import 'package:flutter/services.dart';

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
