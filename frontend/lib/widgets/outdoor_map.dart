import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapRectangle extends StatefulWidget {
  final LatLng location;

  const MapRectangle({super.key, required this.location});

  @override
  State<MapRectangle> createState() => _MapRectangleState();
}

class _MapRectangleState extends State<MapRectangle> {
  late MapController _mapController;
  List<Marker> _buildingMarkers = [];
  String? _selectedBuildingName;
  String? _selectedBuildingAddress;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadBuildingLocations();
  }

  Future<void> _loadBuildingLocations() async {
    print("🔄 _loadBuildingLocations() is running...");

    try {
      final String data = await rootBundle.loadString('assets/geojson_files/building_list.geojson');
      print("✅ GeoJSON file loaded successfully!");

      final Map<String, dynamic> jsonData = jsonDecode(data);
      List<Marker> markers = [];

      if (jsonData['features'] is List) {
        for (var feature in jsonData['features']) {
          if (feature['geometry'] != null &&
              feature['geometry']['type'] == 'Point' &&
              feature['geometry']['coordinates'] is List) {
            List<dynamic> coordinates = feature['geometry']['coordinates'];
            double lon = coordinates[0];
            double lat = coordinates[1];

            String buildingName = feature['properties']['Building Long Name'] ?? "Unknown";
            String address = feature['properties']['Address'] ?? "No address available";

            print("📍 Adding marker at: ($lat, $lon) - $buildingName");

            markers.add(
              Marker(
                point: LatLng(lat, lon),
                width: 40.0,
                height: 40.0,
                child: GestureDetector(
                  onTap: () => _onMarkerTapped(lat, lon, buildingName, address),
                  child: const Icon(Icons.location_pin, color: Color(0xFF912338), size: 40.0),
                ),
              ),
            );
          }
        }
      }

      setState(() {
        _buildingMarkers = markers;
      });

      print("🎯 Total markers loaded: ${_buildingMarkers.length}");
    } catch (e) {
      print('❌ Error loading GeoJSON: $e');
    }
  }

  void _onMarkerTapped(double lat, double lon, String name, String address) {
    setState(() {
      _selectedBuildingName = name;
      _selectedBuildingAddress = address;
      _mapController.move(LatLng(lat, lon), 17.0); // Center map on clicked pin
    });
  }

  @override
  void didUpdateWidget(MapRectangle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
    }
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
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.location,
                    initialZoom: 14.0,
                    minZoom: 11.0,
                    maxZoom: 17.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        // Marker(
                        //   point: LatLng(45.497856, -73.579588),
                        //   width: 40.0,
                        //   height: 40.0,
                        //   child: GestureDetector(
                        //     onTap: () => _onMarkerTapped(45.497856, -73.579588, "Building A", "123 Example St"),
                        //     child: const Icon(Icons.location_pin, color: Color(0xFF912338), size: 40.0),
                        //   ),
                        // ),
                        // Marker(
                        //   point: LatLng(45.4581, -73.6391),
                        //   width: 40.0,
                        //   height: 40.0,
                        //   child: GestureDetector(
                        //     onTap: () => _onMarkerTapped(45.4581, -73.6391, "Building B", "456 Another St"),
                        //     child: const Icon(Icons.location_pin, color: Color(0xFF912338), size: 40.0),
                        //   ),
                        // ),
                        ..._buildingMarkers,
                      ],
                    ),
                  ],
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
}
