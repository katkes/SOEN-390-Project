// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class CampusMap extends StatefulWidget {
//   const CampusMap({super.key});

//   @override
//   State<CampusMap> createState() => _CampusMapState();
// }

// class _CampusMapState extends State<CampusMap> {
//   late final MapController _mapController;
//   final List<Polygon> _buildingPolygons = [];

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     print("initState() called: initializing map controller.");
//     _loadBuildingBoundaries();
//   }

//   @override
//   void dispose() {
//     _mapController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBuildingBoundaries() async {
//     print("Loading building boundaries from: assets/geojson_files/building_boundaries.geojson");

//     try {
//       final String data = await rootBundle
//           .loadString('assets/geojson_files/building_boundaries.geojson');
//       final Map<String, dynamic> jsonData = jsonDecode(data);

//       if (jsonData['features'] is! List) {
//         print("Unexpected GeoJSON format: Missing 'features' list.");
//         return;
//       }

//       for (var feature in jsonData['features']) {
//         if (feature['geometry']?['type'] == 'Polygon' &&
//             feature['geometry']['coordinates'] is List) {
//           List<List<dynamic>> rawCoordinates = List<List<dynamic>>.from(feature['geometry']['coordinates']);
//           List<LatLng> polygonPoints = rawCoordinates[0].map((point) {
//             List<dynamic> coords = List<dynamic>.from(point);
//             print("WORKED");
//             return LatLng(coords[1] as double, coords[0] as double);
//           }).toList();

//           if (polygonPoints.length < 3) {
//             print("Skipping invalid polygon with less than 3 points.");
//             continue;
//           }

//           _buildingPolygons.add(
//             Polygon(
//               points: polygonPoints,
//               borderColor: Colors.blue,
//               borderStrokeWidth: 2.0,
//               color: Colors.blue.withAlpha((0.5 * 255).toInt()),
//             ),
//           );
//         }
//       }

//       print("Buildings loaded: ${_buildingPolygons.length} polygons.");
//     } catch (e) {
//       print("Error loading GeoJSON: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("build() called: UI is building.");

//     return Scaffold(
//       appBar: AppBar(title: const Text('Campus Buildings')),
//       body: FlutterMap(
//         mapController: _mapController,
//         options: const MapOptions(
//           initialCenter: LatLng(45.4965, -73.5862),
//           initialZoom: 16.0,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//           ),
//           if (_buildingPolygons.isNotEmpty)
//             PolygonLayer(polygons: _buildingPolygons),
//         ],
//       ),
//     );
//   }
// }
