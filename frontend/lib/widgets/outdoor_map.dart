import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'building_information_popup.dart';
import 'package:popover/popover.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http; // Import http

// This widget displays a map with markers at specific locations (SGW and Loyola campuses).
class MapWidget extends StatefulWidget {
  // Rename to MapWidget
  final LatLng location;
  final http.Client httpClient; // Add httpClient

  const MapWidget(
      {super.key, required this.location, required this.httpClient});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  // Rename State
  late MapController _mapController;
  List<Marker> _buildingMarkers = [];
  List<Polygon> _buildingPolygons = [];
  String? _selectedBuildingName;
  String? _selectedBuildingAddress;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadBuildingLocations();
    _loadBuildingBoundaries();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    // Update type
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
    }
  }

  Future<void> _loadBuildingLocations() async {
    try {
      print('Loading building markers...');
      final String data = await rootBundle
          .loadString('assets/geojson_files/building_list.geojson');
      print('Building markers file loaded successfully.');

      final Map<String, dynamic> jsonData = jsonDecode(data);
      List<Marker> markers = [];

      if (jsonData['features'] is List) {
        print('Found ${jsonData['features'].length} buildings in the file.');
        for (var feature in jsonData['features']) {
          if (feature['geometry']?['type'] == 'Point' &&
              feature['geometry']['coordinates'] is List) {
            List<dynamic> coordinates = feature['geometry']['coordinates'];
            double lon = coordinates[0];
            double lat = coordinates[1];

            String buildingName =
                feature['properties']['Building Long Name'] ?? "Unknown";
            String address =
                feature['properties']['Address'] ?? "No address available";

            markers.add(
              Marker(
                point: LatLng(lat, lon),
                width: 40.0,
                height: 40.0,
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    Offset tapPosition =
                        renderBox.globalToLocal(details.globalPosition);
                    _onMarkerTapped(
                        lat, lon, buildingName, address, tapPosition);
                  },
                  child: const Icon(Icons.location_pin,
                      color: Color(0xFF912338), size: 40.0),
                ),
              ),
            );
          }
        }
      }

      setState(() {
        _buildingMarkers = markers;
      });
    } catch (e) {
      print('Error loading building markers: $e');
    }
  }

  Future<void> _loadBuildingBoundaries() async {
    try {
      print('Loading building boundaries...');
      final String data = await rootBundle
          .loadString('assets/geojson_files/building_boundaries.geojson');
      print('Building boundaries file loaded successfully.');

      final Map<String, dynamic> jsonData = jsonDecode(data);
      List<Polygon> polygons = [];

      if (jsonData['features'] is List) {
        print(
            'Found ${jsonData['features'].length} buildings with boundaries.');
        for (var feature in jsonData['features']) {
          if (feature['geometry']?['type'] == 'MultiPolygon' &&
              feature['geometry']['coordinates'] is List) {
            // MultiPolygon is a list of polygon rings
            List<dynamic> multiPolygon = feature['geometry']['coordinates'];

            for (var polygonRings in multiPolygon) {
              List<dynamic> outerRing = polygonRings[0];

              try {
                List<LatLng> polygonPoints = outerRing
                    .map<LatLng>((coord) => LatLng(
                          coord[1].toDouble(),
                          coord[0].toDouble(),
                        ))
                    .toList();

                if (polygonPoints.first != polygonPoints.last) {
                  polygonPoints.add(polygonPoints.first);
                }

                print('Creating polygon with ${polygonPoints.length} points');
                print('First point: ${polygonPoints.first}');
                print('Last point: ${polygonPoints.last}');

                polygons.add(
                  Polygon(
                    points: polygonPoints,
                    color: const Color(0x33FF0000),
                    borderColor: Colors.red,
                    borderStrokeWidth: 2,
                    label: feature['properties']?['unique_id']?.toString() ??
                        'Unknown Building',
                  ),
                );
              } catch (e) {
                print('Error creating polygon points: $e');
                continue;
              }
            }
          }
        }
      }

      setState(() {
        _buildingPolygons = polygons;
      });
      print(
          'Building boundaries successfully added to the map: ${polygons.length} polygons');
    } catch (e) {
      print('Error loading building boundaries: $e');
      print('Error details: ${e.toString()}');
    }
  }

  void _onMarkerTapped(
      double lat, double lon, String name, String address, Offset tapPosition) {
    setState(() {
      _selectedBuildingName = name;
      _selectedBuildingAddress = address;
      _mapController.move(LatLng(lat, lon), 17.0);
      print(
          'Selected Building: $_selectedBuildingName, $_selectedBuildingAddress');
    });
    final screenSize = MediaQuery.of(context).size;
    final shouldShowAbove = tapPosition.dy > screenSize.height / 2;
    Future.delayed(Duration(milliseconds: 200), () {
      showPopover(
        context: context,
        bodyBuilder: (context) => BuildingInformationPopup(
          buildingName: name,
          buildingAddress: address,
        ),
        onPop: () => print('Popover closed'),
        direction:
            shouldShowAbove ? PopoverDirection.top : PopoverDirection.bottom,
        width: 220,
        height: 180,
        arrowHeight: 15,
        arrowWidth: 20,
        backgroundColor: Colors.white,
        barrierColor: Colors.transparent,
        radius: 8,
        arrowDyOffset: tapPosition.dy,
      );
    });
  }

 @override
Widget build(BuildContext context) {
  return SizedBox(
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
            additionalOptions: const {}, 
            tileProvider: NetworkTileProvider(httpClient: widget.httpClient),
          ),
           PolygonLayer(
            polygons: _buildingPolygons, 
          ),
          MarkerLayer(
            markers: [
              ..._buildingMarkers, // Add your dynamic markers here
              Marker(
                point: LatLng(45.497856, -73.579588),
                width: 40.0,
                height: 40.0,
                child: const Icon(Icons.location_pin,
                    color: Color(0xFF912338), size: 40.0),
              ),
              Marker(
                point: LatLng(45.4581, -73.6391),
                width: 40.0,
                height: 40.0,
                child: const Icon(Icons.location_pin,
                    color: Color(0xFF912338), size: 40.0),
              ),
            ],
          ),
         
        ],
      ),
    ),
  );
}

}

// How to use it:
class MyPage extends StatelessWidget {
  final http.Client httpClient; // Ensure it's passed here
  final LatLng location;

  const MyPage({required this.httpClient, required this.location, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MapWidget(
          location: location,
          httpClient: httpClient, // Pass the client correctly
        ),
      ),
    );
  }
}
