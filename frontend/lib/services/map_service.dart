import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

/// Service for handling map-related operations and data processing.
///
/// This service is responsible for:
/// * Loading and parsing GeoJSON building data
/// * Creating map markers for buildings
/// * Handling building polygon creation
/// * Managing map styling constants
///
/// Example usage:
/// ```dart
/// final mapService = MapService();
/// final markers = await mapService.loadBuildingMarkers((lat, lon, name, address, pos) {
///   print('Marker tapped: $name');
/// });
/// ```
class MapService {
  static const Color markerColor = Color(0xFF912338);
  static const Color polygonFillColor = Color(0x33FF0000);
  static const Color polygonBorderColor = Colors.red;
  static const double markerSize = 40.0;
  static const double borderStrokeWidth = 2.0;

  Future<List<Marker>> loadBuildingMarkers(Function onMarkerTapped) async {
    try {
      final String data = await rootBundle
          .loadString('assets/geojson_files/building_list.geojson');
      final Map<String, dynamic> jsonData = jsonDecode(data);

      return _parseMarkers(jsonData, onMarkerTapped);
    } catch (e) {
      debugPrint('Error loading building markers: $e');
      return [];
    }
  }

  List<Marker> _parseMarkers(
      Map<String, dynamic> jsonData, Function onMarkerTapped) {
    List<Marker> markers = [];

    if (jsonData['features'] is List) {
      for (var feature in jsonData['features']) {
        var geometry = feature['geometry'];
        var properties = feature['properties'];

        if (geometry?['type'] == 'Point' && geometry['coordinates'] is List) {
          double lon = geometry['coordinates'][0];
          double lat = geometry['coordinates'][1];
          String name = properties?['Building Long Name'] ?? "Unknown";
          String address = properties?['Address'] ?? "No address available";

          markers.add(
            Marker(
              point: LatLng(lat, lon),
              width: markerSize,
              height: markerSize,
              child: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  onMarkerTapped(
                      lat, lon, name, address, details.globalPosition);
                },
                child: const Icon(Icons.location_pin,
                    color: markerColor, size: markerSize),
              ),
            ),
          );
        }
      }
    }
    return markers;
  }

  Future<List<Polygon>> loadBuildingPolygons() async {
    try {
      final String data = await rootBundle
          .loadString('assets/geojson_files/building_boundaries.geojson');
      final Map<String, dynamic> jsonData = jsonDecode(data);

      return _parsePolygons(jsonData);
    } catch (e) {
      debugPrint('Error loading building boundaries: $e');
      return [];
    }
  }

  List<Polygon> _parsePolygons(Map<String, dynamic> jsonData) {
    List<Polygon> polygons = [];

    if (jsonData['features'] is List) {
      for (var feature in jsonData['features']) {
        var geometry = feature['geometry'];

        if (geometry?['type'] == 'MultiPolygon' &&
            geometry['coordinates'] is List) {
          for (var polygonRings in geometry['coordinates']) {
            List<LatLng> polygonPoints = polygonRings[0]
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();

            if (polygonPoints.isNotEmpty &&
                polygonPoints.first != polygonPoints.last) {
              polygonPoints.add(polygonPoints.first);
            }

            polygons.add(
              Polygon(
                points: polygonPoints,
                color: polygonFillColor,
                borderColor: polygonBorderColor,
                borderStrokeWidth: borderStrokeWidth,
              ),
            );
          }
        }
      }
    }
    return polygons;
  }

  Future<LatLng?> searchBuilding(String buildingName) async {
    try {
      final String data = await rootBundle
          .loadString('assets/geojson_files/building_list.geojson');
      final Map<String, dynamic> jsonData = jsonDecode(data);

      for (var feature in jsonData['features']) {
        var properties = feature['properties'];
        var geometry = feature['geometry'];

        if (geometry?['type'] == 'Point' && geometry['coordinates'] is List) {
          String name = properties?['Building Long Name'] ?? "Unknown";
          if (name.toLowerCase().contains(buildingName.toLowerCase())) {
            double lon = geometry['coordinates'][0];
            double lat = geometry['coordinates'][1];
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching for building: $e');
    }
    return null;
  }

  Future<List<String>> getBuildingSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];

      final String data = await rootBundle
          .loadString('assets/geojson_files/building_list.geojson');
      final Map<String, dynamic> jsonData = jsonDecode(data);
      List<String> suggestions = [];

      for (var feature in jsonData['features']) {
        var properties = feature['properties'];
        String name = properties?['Building Long Name'] ?? "Unknown";

        if (name.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(name);
        }
      }
      return suggestions.take(1).toList();
    } catch (e) {
      debugPrint('Error getting building suggestions: $e');
      return [];
    }
  }
}
