import 'dart:convert';
import 'dart:async';
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
  static const Color secondaryMarkerColor = Color.fromARGB(255, 255, 39, 39);
  static const Color polygonBorderColor = Colors.red;
  static const double markerSize = 40.0;
  static const double borderStrokeWidth = 2.0;

  LatLng? _selectedMarkerLocation;
  Timer? _markerClearTimer;
  Function? onMarkerCleared;

  void selectMarker(LatLng location) {
    _selectedMarkerLocation = location;
    _startClearTimer();
  }

  LatLng? get selectedMarkerLocation => _selectedMarkerLocation;

  void _startClearTimer() {
    _markerClearTimer?.cancel();
    _markerClearTimer = Timer(const Duration(seconds: 7), () {
      _selectedMarkerLocation = null;
      _markerClearTimer = null;
      if (onMarkerCleared != null) {
        onMarkerCleared!();
      }
    });
  }

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

          final currentLocation = LatLng(lat, lon);

          // Check if this marker is the selected one
          bool isSelected = _selectedMarkerLocation != null &&
              _selectedMarkerLocation!.latitude == lat &&
              _selectedMarkerLocation!.longitude == lon;

          // Use red for selected marker, default color otherwise
          Color markerColor = isSelected
              ? MapService.secondaryMarkerColor
              : MapService.markerColor;

          markers.add(
            Marker(
              point: currentLocation,
              width: markerSize,
              height: markerSize,
              child: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  onMarkerTapped(
                      lat, lon, name, address, details.globalPosition);
                },
                child: Icon(Icons.location_pin,
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

  //searches building by name and returns its location and details
  Future<Map<String, dynamic>?> searchBuildingWithDetails(
      String buildingName) async {
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
            String address = properties?['Address'] ?? "No address available";

            return {
              'location': LatLng(lat, lon),
              'name': name,
              'address': address
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching for building with details: $e');
    }
    return null;
  }

  Future<String?> findCampusForBuilding(String buildingName) async {
    try {
      final String data = await rootBundle
          .loadString('assets/geojson_files/building_list.geojson');
      final Map<String, dynamic> jsonData = jsonDecode(data);

      if (jsonData['features'] is List) {
        for (var feature in jsonData['features']) {
          var properties = feature['properties'];

          // Check if the building name matches the one in the GeoJSON data
          if (properties?['Building Long Name'] == buildingName) {
            return properties?['Campus'] ??
                "Unknown Campus"; // Return the campus name
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading campus data: $e');
    }
    return null; // Return null if no matching building is found
  }
}
