import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

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
}
