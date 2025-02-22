// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MapRectangle extends StatefulWidget {
//   final LatLng location;

//   const MapRectangle({super.key, required this.location});

//   @override
//   State<MapRectangle> createState() => _MapRectangleState();
// }

// class _MapRectangleState extends State<MapRectangle> {
//   late MapController _mapController;
//   List<Marker> _buildingMarkers = [];
//   String? _selectedBuildingName;
//   String? _selectedBuildingAddress;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _loadBuildingLocations();
//   }

//   Future<void> _loadBuildingLocations() async {
//     print("🔄 _loadBuildingLocations() is running...");

//     try {
//       final String data = await rootBundle.loadString('assets/geojson_files/building_list.geojson');
//       print("✅ GeoJSON file loaded successfully!");

//       final Map<String, dynamic> jsonData = jsonDecode(data);
//       List<Marker> markers = [];

//       if (jsonData['features'] is List) {
//         for (var feature in jsonData['features']) {
//           if (feature['geometry'] != null &&
//               feature['geometry']['type'] == 'Point' &&
//               feature['geometry']['coordinates'] is List) {
//             List<dynamic> coordinates = feature['geometry']['coordinates'];
//             double lon = coordinates[0];
//             double lat = coordinates[1];

//             String buildingName = feature['properties']['Building Long Name'] ?? "Unknown";
//             String address = feature['properties']['Address'] ?? "No address available";

//             print("📍 Adding marker at: ($lat, $lon) - $buildingName");

//             markers.add(
//               Marker(
//                 point: LatLng(lat, lon),
//                 width: 40.0,
//                 height: 40.0,
//                 child: GestureDetector(
//                   onTap: () => _onMarkerTapped(lat, lon, buildingName, address),
//                   child: const Icon(Icons.location_pin, color: Color(0xFF912338), size: 40.0),
//                 ),
//               ),
//             );
//           }
//         }
//       }

//       setState(() {
//         _buildingMarkers = markers;
//       });

//       print("🎯 Total markers loaded: ${_buildingMarkers.length}");
//     } catch (e) {
//       print('❌ Error loading GeoJSON: $e');
//     }
//   }

//   void _onMarkerTapped(double lat, double lon, String name, String address) {
//     setState(() {
//       _selectedBuildingName = name;
//       _selectedBuildingAddress = address;
//       _mapController.move(LatLng(lat, lon), 17.0); // Center map on clicked pin
//     });
//   }

//   @override
//   void didUpdateWidget(MapRectangle oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.location != widget.location) {
//       _mapController.move(widget.location, 17.0);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           bottom: 5,
//           left: 10,
//           right: 10,
//           child: Center(
//             child: SizedBox(
//               width: 460,
//               height: 570,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: widget.location,
//                     initialZoom: 14.0,
//                     minZoom: 11.0,
//                     maxZoom: 17.0,
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
//                     ),
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                     ),
//                     MarkerLayer(
//                       markers: [
//                         // Marker(
//                         //   point: LatLng(45.497856, -73.579588),
//                         //   width: 40.0,
//                         //   height: 40.0,
//                         //   child: GestureDetector(
//                         //     onTap: () => _onMarkerTapped(45.497856, -73.579588, "Building A", "123 Example St"),
//                         //     child: const Icon(Icons.location_pin, color: Color(0xFF912338), size: 40.0),
//                         //   ),
//                         // ),
//                         // Marker(
//                         //   point: LatLng(45.4581, -73.6391),
//                         //   width: 40.0,
//                         //   height: 40.0,
//                         //   child: GestureDetector(
//                         //     onTap: () => _onMarkerTapped(45.4581, -73.6391, "Building B", "456 Another St"),
//                         //     child: const Icon(Icons.location_pin, color: Color(0xFF912338), size: 40.0),
//                         //   ),
//                         // ),
//                         ..._buildingMarkers,
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         if (_selectedBuildingName != null && _selectedBuildingAddress != null)
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: Container(
//               width: 200,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(color: Colors.black26, blurRadius: 5),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _selectedBuildingName!,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     _selectedBuildingAddress!,
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MapRectangle extends StatefulWidget {
//   final LatLng location;

//   const MapRectangle({super.key, required this.location});

//   @override
//   State<MapRectangle> createState() => _MapRectangleState();
// }

// class _MapRectangleState extends State<MapRectangle> {
//   late MapController _mapController;
//   List<Marker> _buildingMarkers = [];
//   List<Polygon> _buildingPolygons = [];
//   String? _selectedBuildingName;
//   String? _selectedBuildingAddress;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _loadBuildingLocations();
//     _loadBuildingBoundaries();
//   }

//   /// Load building markers from GeoJSON file
//   Future<void> _loadBuildingLocations() async {
//     try {
//       print('📌 Loading building markers...');
//       final String data =
//           await rootBundle.loadString('assets/geojson_files/building_list.geojson');
//       print('✅ Building markers file loaded successfully.');

//       final Map<String, dynamic> jsonData = jsonDecode(data);
//       List<Marker> markers = [];

//       if (jsonData['features'] is List) {
//         print('📍 Found ${jsonData['features'].length} buildings in the file.');
//         for (var feature in jsonData['features']) {
//           if (feature['geometry']?['type'] == 'Point' &&
//               feature['geometry']['coordinates'] is List) {
//             List<dynamic> coordinates = feature['geometry']['coordinates'];
//             double lon = coordinates[0];
//             double lat = coordinates[1];

//             String buildingName = feature['properties']['Building Long Name'] ?? "Unknown";
//             String address = feature['properties']['Address'] ?? "No address available";

//             print('➡ Adding marker: $buildingName at ($lat, $lon)');

//             markers.add(
//               Marker(
//                 point: LatLng(lat, lon),
//                 width: 40.0,
//                 height: 40.0,
//                 child: GestureDetector(
//                   onTap: () => _onMarkerTapped(lat, lon, buildingName, address),
//                   child: const Icon(Icons.location_pin, color: Color(0xFF912338), size: 40.0),
//                 ),
//               ),
//             );
//           }
//         }
//       }

//       setState(() {
//         _buildingMarkers = markers;
//       });
//       print('✅ Building markers successfully added to the map.');
//     } catch (e) {
//       print('❌ Error loading building markers: $e');
//     }
//   }

//   /// Load building boundaries (polygons) from a GeoJSON file
//   Future<void> _loadBuildingBoundaries() async {
//     try {
//       print('📌 Loading building boundaries...');
//       final String data =
//           await rootBundle.loadString('assets/geojson_files/building_boundaries.geojson');
//       print('✅ Building boundaries file loaded successfully.');

//       final Map<String, dynamic> jsonData = jsonDecode(data);
//       List<Polygon> polygons = [];

//       if (jsonData['features'] is List) {
//         print('🏢 Found ${jsonData['features'].length} buildings with boundaries.');
//         for (var feature in jsonData['features']) {
//           if (feature['geometry']?['type'] == 'Polygon' &&
//               feature['geometry']['coordinates'] is List) {
//             List<dynamic> coordinates = feature['geometry']['coordinates'][0];

//             List<LatLng> polygonPoints = coordinates
//                 .map<LatLng>((coord) => LatLng(coord[1], coord[0])) // GeoJSON is (lon, lat)
//                 .toList();

//             print('➡ Adding polygon with ${polygonPoints.length} points.');

//             polygons.add(
//               Polygon(
//                 points: polygonPoints,
//                 color: Colors.blue.withOpacity(0.5), // Semi-transparent blue
//                 borderColor: Colors.blueAccent,
//                 borderStrokeWidth: 2,
//               ),
//             );
//           }
//         }
//       }

//       setState(() {
//         _buildingPolygons = polygons;
//       });
//       print('✅ Building boundaries successfully added to the map.');
//     } catch (e) {
//       print('❌ Error loading building boundaries: $e');
//     }
//   }

//   void _onMarkerTapped(double lat, double lon, String name, String address) {
//     print('📍 Marker clicked: $name at ($lat, $lon)');
//     setState(() {
//       _selectedBuildingName = name;
//       _selectedBuildingAddress = address;
//       _mapController.move(LatLng(lat, lon), 17.0); // Center map on clicked pin
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(30),
//             child: FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: widget.location,
//                 initialZoom: 14.0,
//                 minZoom: 11.0,
//                 maxZoom: 17.0,
//                 interactionOptions: const InteractionOptions(
//                   flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
//                 ),
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 ),
//                 PolygonLayer(
//                   polygons: _buildingPolygons, // ✅ Add colored buildings
//                 ),
//                 MarkerLayer(
//                   markers: _buildingMarkers,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (_selectedBuildingName != null && _selectedBuildingAddress != null)
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: Container(
//               width: 200,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _selectedBuildingName!,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     _selectedBuildingAddress!,
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
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

  Future<void> _loadBuildingLocations() async {
    try {
      print('📌 Loading building markers...');
      final String data =
          await rootBundle.loadString('assets/geojson_files/building_list.geojson');
      print('✅ Building markers file loaded successfully.');

      final Map<String, dynamic> jsonData = jsonDecode(data);
      List<Marker> markers = [];

      if (jsonData['features'] is List) {
        print('📍 Found ${jsonData['features'].length} buildings in the file.');
        for (var feature in jsonData['features']) {
          if (feature['geometry']?['type'] == 'Point' &&
              feature['geometry']['coordinates'] is List) {
            List<dynamic> coordinates = feature['geometry']['coordinates'];
            double lon = coordinates[0];
            double lat = coordinates[1];

            String buildingName = feature['properties']['Building Long Name'] ?? "Unknown";
            String address = feature['properties']['Address'] ?? "No address available";

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
    } catch (e) {
      print('❌ Error loading building markers: $e');
    }
  }

  Future<void> _loadBuildingBoundaries() async {
    try {
      print('📌 Loading building boundaries...');
      final String data =
          await rootBundle.loadString('assets/geojson_files/building_boundaries.geojson');
      print('✅ Building boundaries file loaded successfully.');

      final Map<String, dynamic> jsonData = jsonDecode(data);
      List<Polygon> polygons = [];

      if (jsonData['features'] is List) {
        print('🏢 Found ${jsonData['features'].length} buildings with boundaries.');
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
                    label: feature['properties']?['unique_id']?.toString() ?? 'Unknown Building',
                  ),
                );
              } catch (e) {
                print('❌ Error creating polygon points: $e');
                continue;
              }
            }
          }
        }
      }

      setState(() {
        _buildingPolygons = polygons;
      });
      print('✅ Building boundaries successfully added to the map: ${polygons.length} polygons');
    } catch (e) {
      print('❌ Error loading building boundaries: $e');
      print('Error details: ${e.toString()}');
    }
  }

  void _onMarkerTapped(double lat, double lon, String name, String address) {
    setState(() {
      _selectedBuildingName = name;
      _selectedBuildingAddress = address;
      _mapController.move(LatLng(lat, lon), 17.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
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
                PolygonLayer(
                  polygons: _buildingPolygons,
                ),
                MarkerLayer(
                  markers: _buildingMarkers,
                ),
              ],
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
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
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
