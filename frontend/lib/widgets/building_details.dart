import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BuildingBoundariesMap extends StatefulWidget {
  const BuildingBoundariesMap({super.key});

  @override
  State<BuildingBoundariesMap> createState() => _BuildingBoundariesMapState();
}

class _BuildingBoundariesMapState extends State<BuildingBoundariesMap> {
  late MapController _mapController;
  List<Polygon> _buildingPolygons = [];
  String? _selectedBuildingName;
  String? _selectedBuildingAddress;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadBuildingBoundaries();
  }

  Future<void> _loadBuildingBoundaries() async {
    try {
      final String data =
      await rootBundle.loadString('assets/geojson_files/building_boundaries.geojson');
      print("✅ GeoJSON file loaded successfully2 !");
      final Map<String, dynamic> jsonData = jsonDecode(data);
      List<Polygon> polygons = [];

      if (jsonData['features'] is List) {
        for (var feature in jsonData['features']) {
          if (feature['geometry'] != null &&
              feature['geometry']['type'] == 'Polygon' &&
              feature['geometry']['coordinates'] is List) {
            List<dynamic> coordinates = feature['geometry']['coordinates'][0];
            List<LatLng> latLngPoints = coordinates.map<LatLng>((coord) {
              return LatLng(coord[1], coord[0]);
            }).toList();

            String buildingName = feature['properties']['Building Long Name'] ?? "Unknown";
            String address = feature['properties']['Address'] ?? "No address available";

            polygons.add(
              Polygon(
                points: latLngPoints,
                color: Colors.blue.withOpacity(0.3), // Semi-transparent fill
                borderColor: Colors.blue, // Solid border
                borderStrokeWidth: 2,
              ),
            );
          }
        }
      }

      setState(() {
        _buildingPolygons = polygons;
      });
    } catch (e) {
      print('❌ Error loading GeoJSON: $e');
    }
  }

  void _onPolygonTapped(String name, String address) {
    setState(() {
      _selectedBuildingName = name;
      _selectedBuildingAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 5,
          left: 10,
          right: 10,
          child: Center(
            child: SizedBox(
              width: 460,
              height: 570,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: GestureDetector(
                  onTapUp: (TapUpDetails details) {
                    final tapPosition = details.localPosition;

                    // Get the map's bounds (top-left and bottom-right coordinates)
                    final bounds = _mapController.camera.visibleBounds;

                    // Extract coordinates from the bounds
                    final topLeft = bounds.northWest;
                    final bottomRight = bounds.southEast;

                    // Calculate relative position
                    double latitude = topLeft.latitude +
                        ((bottomRight.latitude - topLeft.latitude) * (tapPosition.dy / 570));
                    double longitude = topLeft.longitude +
                        ((bottomRight.longitude - topLeft.longitude) * (tapPosition.dx / 460));

                    LatLng tappedPoint = LatLng(latitude, longitude);

                    for (var polygon in _buildingPolygons) {
                      if (_isPointInsidePolygon(tappedPoint, polygon.points)) {
                        _onPolygonTapped("Building Name", "Building Address");
                        break;
                      }
                    }
                  },
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(45.497856, -73.579588), // Default location
                      initialZoom: 14.0,
                      minZoom: 11.0,
                      maxZoom: 17.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      PolygonLayer(polygons: _buildingPolygons),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_selectedBuildingName != null && _selectedBuildingAddress != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBuildingName!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _selectedBuildingAddress!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  bool _isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng p1 = polygon[j];
      LatLng p2 = polygon[j + 1];

      if ((p1.latitude > point.latitude) != (p2.latitude > point.latitude) &&
          (point.longitude <
              (p2.longitude - p1.longitude) *
                  (point.latitude - p1.latitude) /
                  (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }
}
