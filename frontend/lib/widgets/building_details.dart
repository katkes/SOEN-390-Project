import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class CampusMap extends StatefulWidget {
  final http.Client? httpClient;

  const CampusMap({Key? key, this.httpClient}) : super(key: key);
  @override
  State<CampusMap> createState() => _CampusMapState();
}

class _CampusMapState extends State<CampusMap> {
  late final MapController _mapController;
  final List<Polygon> _buildingPolygons = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    print("initState() called: initializing map controller.");
    _loadBuildingBoundaries();
  }

  @override
  void dispose() {
    _mapController.dispose(); // Proper cleanup
    super.dispose();
  }

  Future<void> _loadBuildingBoundaries() async {
    print("Loading building boundaries...");

    try {
      String data;

      if (widget.httpClient != null) {
        final response = await widget.httpClient!.get(Uri.parse('YOUR_API_URL'));
        data = response.body;
      } else {
        data = await rootBundle.loadString('assets/geojson_files/building_boundaries.geojson');
      }

      final Map<String, dynamic> jsonData = jsonDecode(data);
      if (jsonData['features'] is! List) {
        print("Unexpected GeoJSON format: Missing 'features' list.");
        return;
      }
    } catch (e) {
      print("Error loading GeoJSON: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    print("build() called: UI is building.");

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Buildings')),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(45.4965, -73.5862),
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (_buildingPolygons.isNotEmpty)
            PolygonLayer(polygons: _buildingPolygons),
        ],
      ),
    );
  }
}
