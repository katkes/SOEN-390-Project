import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:http/http.dart' as http;

/// A widget that displays an interactive map with routing functionality.
///
/// The map allows users to visualize locations, interact with markers,
/// and calculate routes between two selected points using the injected `IRouteService`.
import 'building_information_popup.dart';
import 'package:popover/popover.dart';

//import 'package:soen_390/services/route_service.dart';
// ignore: depend_on_referenced_packages

import '../services/building_info_api.dart';

class MapWidget extends StatefulWidget {
  /// The initial location where the map is centered.

  final LatLng location;

  /// The HTTP client used for network requests related to map tiles.
  final http.Client httpClient;

  /// The route service responsible for fetching route data.
  final IRouteService routeService;

  final GoogleMapsApiClient mapsApiClient;
  final BuildingPopUps buildingPopUps;

  /// Creates an instance of `MapWidget` with required dependencies.
  ///
  /// - [location]: The initial `LatLng` location for the map.
  /// - [httpClient]: The HTTP client used for loading map tiles.
  /// - [routeService]: The service used to fetch navigation routes.
  const MapWidget(
      {super.key,
      required this.location,
      required this.httpClient,
      required this.routeService,
      required this.mapsApiClient,
      required this.buildingPopUps});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _mapController;
  List<Marker> _buildingMarkers = [];
  List<Polygon> _buildingPolygons = [];
  String? _selectedBuildingName;
  String? _selectedBuildingAddress;

  /// The starting location for route calculation.
  late LatLng from;

  /// The destination location for route calculation.
  late LatLng to;

  /// A list of `LatLng` points representing the route path.
  List<LatLng> routePoints = [];

  /// The total distance of the calculated route in meters.
  double distance = 0.0;

  /// The estimated travel duration of the calculated route in seconds.
  double duration = 0.0;

  /// Used to alternate taps for selecting route start (`from`) and destination (`to`).

  bool isPairly = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadBuildingLocations();
    _loadBuildingBoundaries();

    from = widget.location;
    to = LatLng(
        widget.location.latitude + 0.005, widget.location.longitude + 0.005);
    _fetchRoute();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
      from = widget.location;
      _fetchRoute();
    }
  }
  //MapController get mapController => _mapController; //NEW

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
      List<Polygon> polygons = _extractPolygons(jsonData);

      setState(() {
        _buildingPolygons = polygons;
        print("Loaded ${_buildingPolygons.length} building polygons.");
      });
      print(
          'Building boundaries successfully added to the map: ${polygons.length} polygons');
    } catch (e) {
      print('Error loading building boundaries: $e');
    }
  }

  List<Polygon> _extractPolygons(Map<String, dynamic> jsonData) {
    List<Polygon> polygons = [];
    if (jsonData['features'] is List) {
      print('Found ${jsonData['features'].length} buildings with boundaries.');
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
      for (var polygonRings in geometry['coordinates']) {
        _addPolygon(polygonRings, feature, polygons);
      }
    }
  }

  void _addPolygon(List<dynamic> polygonRings, Map<String, dynamic> feature,
      List<Polygon> polygons) {
    List<dynamic> outerRing = polygonRings[0];
    try {
      List<LatLng> polygonPoints = outerRing
          .map<LatLng>(
              (coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
          .toList();
      
      if (polygonPoints.isNotEmpty &&
          polygonPoints.first != polygonPoints.last) {
        polygonPoints.add(polygonPoints.first);
      }
      
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

    widget.buildingPopUps
        .fetchBuildingInformation(lat, lon, name)
        .then((buildingInfo) {
      String? photoUrl = buildingInfo["photo"];
      print("Fetched photo URL: $photoUrl");

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return; // Ensure the widget is still mounted
        showPopover(
          context: context,
          bodyBuilder: (context) => BuildingInformationPopup(
            buildingName: name,
            buildingAddress: address,
            photoUrl: photoUrl,
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

    }).catchError((error) {
      print("Error fetching building photo: $error");
    });
  }

  /// Fetches a route from `from` to `to` using the injected `IRouteService`.
  ///
  /// The result updates the state with new distance, duration, and route points.
  Future<void> _fetchRoute() async {
    final routeResult = await widget.routeService.getRoute(from: from, to: to);

    if (routeResult == null || routeResult.routePoints.isEmpty) {
      // If no route is found or if the route points list is empty, we can either clear the polyline or handle accordingly
      setState(() {
        distance = 0.0;
        duration = 0.0;
        routePoints = []; // Clear the route points if no route is found
      });
      return;
    }

    setState(() {
      distance = routeResult.distance;
      duration = routeResult.duration;
      routePoints = routeResult.routePoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.location,
            initialZoom: 14.0,
            minZoom: 11.0,
            maxZoom: 17.0,
            onTap: _handleMapTap,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              additionalOptions: const {}, // Add this line
              tileProvider: NetworkTileProvider(httpClient: widget.httpClient),
            ),
            //Used for testing
            // Only render the polyline layer if there are valid route points
            // if (routePoints.isNotEmpty)
            //   PolylineLayer(
            //     polylines: [
            //       Polyline(
            //         points: routePoints,
            //         strokeWidth: 4.0,
            //         color: Colors.blueAccent,
            //       ),
            //     ],
            //   ),

            // MarkerLayer(markers: _buildMarkers()),
            PolygonLayer(
              polygons: _buildingPolygons,
            ),
            MarkerLayer(
              markers: [
                ..._buildingMarkers, // Include existing _buildingMarkers
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

  /// Handles user taps on the map to set the `from` and `to` locations.
  ///
  /// - If `isPairly` is false, updates `from` location.
  /// - Otherwise, updates `to` location.
  /// - Toggles `isPairly` after every selection.
  /// - Calls `_fetchRoute()` to update the route accordingly.
  void _handleMapTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      if (!isPairly) {
        from = latLng;
      } else {
        to = latLng;
      }
      isPairly = !isPairly;
      _fetchRoute();
    });
  }

  /// Builds a list of markers for the map, including:
  /// - The `from` location (blue marker).
  /// - The `to` location (green marker).
  /// Used for testing
  // List<Marker> _buildMarkers() {
  //   return [
  //     Marker(
  //       point: from,
  //       width: 40.0,
  //       height: 40.0,
  //       child: const Icon(Icons.location_pin, color: Colors.blue, size: 40.0),
  //     ),
  //     Marker(
  //       point: to,
  //       width: 40.0,
  //       height: 40.0,
  //       child: const Icon(Icons.location_pin, color: Colors.green, size: 40.0),
  //     ),
  //   ];
  // }
}

/// Example usage of `MapWidget` inside a `MyPage` scaffold.
class MyPage extends StatelessWidget {
  /// The injected route service for fetching navigation routes.
  final IRouteService routeService;

  /// The injected HTTP client for loading map tiles.
  final http.Client httpClient;

  /// The initial location for the map.

  final LatLng location;
  final GoogleMapsApiClient mapsApiClient;
  final BuildingPopUps buildingPopUps;

  /// Creates a `MyPage` instance with necessary dependencies.
  const MyPage({
    required this.httpClient,
    required this.location,
    required this.routeService,
    required this.mapsApiClient,
    required this.buildingPopUps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mapsApiClient = GoogleMapsApiClient(
      apiKey: "GOOGLE_MAPS_API_KEY",
      client: httpClient,
    );

    final buildingPopUps = BuildingPopUps(
      mapsApiClient: mapsApiClient,
    );
    return Scaffold(
      body: Center(
        child: MapWidget(
          location: location,
          httpClient: httpClient,
          routeService: routeService,
          mapsApiClient: mapsApiClient,
          buildingPopUps: buildingPopUps,
        ),
      ),
    );
  }
}
