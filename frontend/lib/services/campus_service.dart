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
  final GeoJsonLoader geoJsonLoader;

  CampusService({GeoJsonLoader? loader})
      : geoJsonLoader = loader ?? GeoJsonLoader();

  Map<String, dynamic>? buildingBoundaries;
  Map<String, dynamic>? buildingList;
  Map<String, dynamic>? campusBoundaries;

  Future<void> loadGeoJsonData() async {
    try {
      buildingBoundaries = await geoJsonLoader
          .load('assets/geojson/building_boundaries.geojson');

      buildingList =
          await geoJsonLoader.load('assets/geojson/building_list.geojson');

      campusBoundaries =
          await geoJsonLoader.load('assets/geojson/campus.geojson');
    } catch (e) {
      print("Error loading GeoJSON files: $e");
    }
  }
}
