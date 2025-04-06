import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:soen_390/repositories/geojson_repository.dart';

class MapService {
  static const Color polygonFillColor = Color(0x33FF0000);
  static const Color polygonBorderColor = Colors.red;
  static const double borderStrokeWidth = 2.0;
  static const String _buildingLongName = 'Building Long Name';

  final GeoJsonRepository _geoJsonRepository;

  LatLng? _selectedPolygonLocation;
  Timer? _polygonClearTimer;
  Function? onPolygonCleared;

  MapService({GeoJsonRepository? geoJsonRepository})
      : _geoJsonRepository = geoJsonRepository ?? GeoJsonRepository();

  void selectPolygon(LatLng location) {
    _selectedPolygonLocation = location;
    startClearTimer();
  }

  LatLng? get selectedPolygonLocation => _selectedPolygonLocation;

  Map<String, dynamic>? getPolygonMetadata(List<LatLng> polygonPoints) {
    return _polygonMetadata[polygonPoints];
  }

  void startClearTimer() {
    _polygonClearTimer?.cancel();
    _polygonClearTimer = Timer(const Duration(seconds: 7), () {
      _selectedPolygonLocation = null;
      _polygonClearTimer = null;
      onPolygonCleared?.call();
    });
  }

  // Load building information from GeoJSON and add to the polygons
  Future<List<Polygon>> loadBuildingInformation(
    Function onPolygonTapped,
    List<Polygon> outdoorMapPolygons, // Accept polygons from OutdoorMap
  ) async {
    try {
      final jsonData = await _geoJsonRepository.loadBuildingList();
      return _parseBuildingPolygons(
          jsonData, onPolygonTapped, outdoorMapPolygons);
    } catch (e) {
      debugPrint('Error loading building list: $e');
      return [];
    }
  }

  // Parse the GeoJSON data and add to existing polygons
  List<Polygon> _parseBuildingPolygons(
    Map<String, dynamic> jsonData,
    Function onMarkerTapped,
    List<Polygon> outdoorMapPolygons, // Accept polygons from OutdoorMap
  ) {
    List<Polygon> polygons = [];

    // Use the polygons from the OutdoorMap widget
    for (var polygon in outdoorMapPolygons) {
      polygons.add(polygon);
    }

    // Parse additional polygons from the GeoJSON data
    if (jsonData['features'] is List) {
      for (var feature in jsonData['features']) {
        var geometry = feature['geometry'];

        // Only process MultiPolygon geometries
        if (geometry?['type'] == 'MultiPolygon' &&
            geometry['coordinates'] is List) {
          for (var polygonRings in geometry['coordinates']) {
            List<LatLng> polygonPoints = _extractPolygonPoints(polygonRings[0]);
            _ensureClosedPolygon(polygonPoints);

            polygons.add(_createPolygon(polygonPoints));
          }
        }
      }
    }

    return polygons;
  }

  // List<Polygon> _parsa(Map<String, dynamic> jsonData,
  //     Function(String, String, LatLng) onPolygonTapped) {
  //   List<Polygon> polygons = [];

  //   if (jsonData['features'] is List) {
  //     for (var feature in jsonData['features']) {
  //       var properties = feature['properties'];
  //       var geometry = feature['geometry'];

  //       // Extract building metadata
  //       String name = properties?[_buildingLongName] ?? "Unknown";
  //       String address = properties?['Address'] ?? "No address available";

  //       if (geometry?['type'] == 'MultiPolygon' &&
  //           geometry['coordinates'] is List) {
  //         for (var polygonRings in geometry['coordinates']) {
  //           List<LatLng> polygonPoints = _extractPolygonPoints(polygonRings[0]);
  //           _ensureClosedPolygon(polygonPoints);

  //           // Calculate the center of the polygon for metadata
  //           LatLng center = _calculatePolygonCenter(polygonPoints);

  //           // Add the polygon to the list
  //           polygons.add(
  //             Polygon(
  //                 points: polygonPoints,
  //                 color: polygonFillColor,
  //                 borderColor: polygonBorderColor,
  //                 borderStrokeWidth: borderStrokeWidth),
  //           );

  //           // Store metadata for the polygon
  //           _polygonMetadata[polygonPoints] = {
  //             'name': name,
  //             'address': address,
  //             'center': center,
  //           };
  //         }
  //       }
  //     }
  //   }
  //   return polygons;
  // }

// Helper method to calculate the center of a polygon
  LatLng _calculatePolygonCenter(List<LatLng> points) {
    double lat = 0.0;
    double lng = 0.0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

// Metadata map to store polygon details
  final Map<List<LatLng>, Map<String, dynamic>> _polygonMetadata = {};

  Future<List<Polygon>> loadBuildingPolygons() async {
    try {
      final jsonData = await _geoJsonRepository.loadBuildingBoundaries();
      return _parsePolygons(jsonData);
    } catch (e) {
      debugPrint('Error loading building polygons: $e');
      return [];
    }
  }

  List<Polygon> _parsePolygons(Map<String, dynamic> jsonData) {
    List<Polygon> polygons = [];

    if (jsonData['features'] is List) {
      for (var feature in jsonData['features']) {
        _processFeature(feature, polygons);
      }
    }
    return polygons;
  }

  void _processFeature(Map<String, dynamic> feature, List<Polygon> polygons) {
    var geometry = feature['geometry'];

    if (geometry?['type'] == 'MultiPolygon' &&
        geometry['coordinates'] is List) {
      _processMultiPolygon(geometry['coordinates'], polygons);
    } else {
      debugPrint(
          'Unexpected geometry type or format: ${geometry?['type']}, coordinates type: ${geometry?['coordinates']?.runtimeType}');
    }
  }

  void _processMultiPolygon(
      List multiPolygonCoordinates, List<Polygon> polygons) {
    for (var polygonRings in multiPolygonCoordinates) {
      List<LatLng> polygonPoints = _extractPolygonPoints(polygonRings[0]);
      _ensureClosedPolygon(polygonPoints);

      polygons.add(_createPolygon(polygonPoints));
    }
  }

  List<LatLng> _extractPolygonPoints(List coordinates) {
    return coordinates
        .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        .toList();
  }

  void _ensureClosedPolygon(List<LatLng> polygonPoints) {
    if (polygonPoints.isNotEmpty && polygonPoints.first != polygonPoints.last) {
      polygonPoints.add(polygonPoints.first);
    }
  }

  Polygon _createPolygon(List<LatLng> points) {
    return Polygon(
      points: points,
      color: polygonFillColor,
      borderColor: polygonBorderColor,
      borderStrokeWidth: borderStrokeWidth,
    );
  }

  Future<List<String>> getBuildingSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];

      final jsonData = await _geoJsonRepository.loadBuildingList();
      List<String> suggestions = [];

      for (var feature in jsonData['features']) {
        var properties = feature['properties'];
        String name = properties?[_buildingLongName] ?? "Unknown";

        if (name.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(name);
        }
      }
      return suggestions.take(1).toList();
    } catch (e) {
      debugPrint('Error getting suggestions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> searchBuildingWithDetails(
      String buildingName) async {
    try {
      final jsonData = await _geoJsonRepository.loadBuildingList();

      for (var feature in jsonData['features']) {
        var properties = feature['properties'];
        var geometry = feature['geometry'];

        if (geometry?['type'] == 'Point' && geometry['coordinates'] is List) {
          String name = properties?[_buildingLongName] ?? "Unknown";
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
      final jsonData = await _geoJsonRepository.loadBuildingList();

      if (jsonData['features'] is List) {
        for (var feature in jsonData['features']) {
          var properties = feature['properties'];

          if (properties?[_buildingLongName] == buildingName) {
            return properties?['Campus'] ?? "Unknown Campus";
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading campus data: $e');
    }
    return null;
  }
}
