import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:soen_390/repositories/geojson_repository.dart';

class MapService {
  static const Color markerColor = Color(0xFF912338);
  static const Color polygonFillColor = Color(0x33FF0000);
  static const Color secondaryMarkerColor = Color.fromARGB(255, 255, 39, 39);
  static const Color polygonBorderColor = Colors.red;
  static const double markerSize = 40.0;
  static const double borderStrokeWidth = 2.0;
  static const String _buildingLongName = 'Building Long Name';

  final GeoJsonRepository _geoJsonRepository;

  LatLng? _selectedMarkerLocation;
  Timer? _markerClearTimer;
  Function? onMarkerCleared;

  MapService({GeoJsonRepository? geoJsonRepository})
      : _geoJsonRepository = geoJsonRepository ?? GeoJsonRepository();

  void selectMarker(LatLng location) {
    _selectedMarkerLocation = location;
    startClearTimer();
  }

  LatLng? get selectedMarkerLocation => _selectedMarkerLocation;

  void startClearTimer() {
    _markerClearTimer?.cancel();
    _markerClearTimer = Timer(const Duration(seconds: 7), () {
      _selectedMarkerLocation = null;
      _markerClearTimer = null;
      onMarkerCleared?.call();
    });
  }

  Future<List<Marker>> loadBuildingMarkers(Function onMarkerTapped) async {
    try {
      final jsonData = await _geoJsonRepository.loadBuildingList();
      return _parseMarkers(jsonData, onMarkerTapped);
    } catch (e) {
      debugPrint('Error loading building markers: $e');
      return [];
    }
  }

  List<Marker> _parseMarkers(
      Map<String, dynamic> jsonData, Function onMarkerTapped) {
    List<String> _availableMapMarkers = [
      'Henry F. Hall Building',
      'Engineering, Computer Science and Visual Arts Integrated Complex',
      'Webster Library Building',
      'Faubourg Building',
      'ER Building',
      'Learning Square LS Building',
      'John Molson Building',
      'Stinger Dome',
      'CC Building',
      'PC Building',
      'VL Building'
    ];
    List<Marker> markers = [];

    if (jsonData['features'] is List) {
      for (var feature in jsonData['features']) {
        if (!_availableMapMarkers
            .contains(feature['properties']?[_buildingLongName])) {
          continue;
        }
        var geometry = feature['geometry'];
        var properties = feature['properties'];

        if (geometry?['type'] == 'Point' && geometry['coordinates'] is List) {
          double lon = geometry['coordinates'][0];
          double lat = geometry['coordinates'][1];
          String name = properties?[_buildingLongName] ?? "Unknown";
          String address = properties?['Address'] ?? "No address available";

          final currentLocation = LatLng(lat, lon);

          bool isSelected = _selectedMarkerLocation != null &&
              _selectedMarkerLocation!.latitude == lat &&
              _selectedMarkerLocation!.longitude == lon;

          Color markerColor = isSelected
              ? MapService.secondaryMarkerColor
              : MapService.markerColor;

          print(
              'Building: $name, Address: $address, Coordinates: ($lat, $lon)');

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
