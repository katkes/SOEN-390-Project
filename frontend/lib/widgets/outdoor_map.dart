import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/services/map_service.dart';
import 'package:soen_390/utils/marker_tap_handler.dart';
import '../services/building_info_api.dart';

/// A widget that displays an interactive map with routing functionality.
///
/// The map allows users to visualize locations, interact with markers,
/// and calculate routes between two selected points using the injected `IRouteService`.
class MapWidget extends StatefulWidget {
  /// The initial location where the map is centered.

  final LatLng location;

  /// The HTTP client used for network requests related to map tiles.
  final http.Client httpClient;

  /// The route service responsible for fetching route data.
  final IRouteService routeService;

  final GoogleMapsApiClient mapsApiClient;
  final BuildingPopUps buildingPopUps;

  /// A list of `LatLng` points representing the route path.
  final List<LatLng> routePoints;

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
      required this.buildingPopUps,
      required this.routePoints});

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

  /// The total distance of the calculated route in meters.
  double distance = 0.0;

  /// The estimated travel duration of the calculated route in seconds.
  double duration = 0.0;

  /// Used to alternate taps for selecting route start (`from`) and destination (`to`).

  bool isPairly = false;

  ///
  late MapService _mapService;

  ///
  late MarkerTapHandler _markerTapHandler;

  List<LatLng> animatedPoints = [];
  int animationIndex = 0;
  Timer? animationTimer;
  double animationProgress = 0.0; // Track progress between points

  @override
  void initState() {
    super.initState();
    //widget.onRoutePointsChanged(routePoints); // this line crashes the map
    _mapController = MapController();
    _mapService = MapService();
    _markerTapHandler = MarkerTapHandler(
      onBuildingInfoUpdated: (name, address) {
        setState(() {
          _selectedBuildingName = name;
          _selectedBuildingAddress = address;
          print(
              'Building selected: Name = $_selectedBuildingName, Address = $_selectedBuildingAddress');
        });
      },
      mapController: _mapController,
      buildingPopUps: widget.buildingPopUps,
    );
    _loadBuildingLocations();
    _loadBuildingBoundaries();
  }

  Future<void> _loadBuildingLocations() async {
    try {
      final markers = await _mapService
          .loadBuildingMarkers((lat, lon, name, address, tapPosition) {
        _markerTapHandler.onMarkerTapped(
            lat, lon, name, address, tapPosition, context);
      });
      setState(() {
        _buildingMarkers = markers;
      });
    } catch (e) {
      print('Error loading building markers: $e');
    }
  }

  /// Loads the building boundaries from the map service
  Future<void> _loadBuildingBoundaries() async {
    try {
      final polygons = await _mapService.loadBuildingPolygons();
      setState(() {
        _buildingPolygons = polygons;
      });
    } catch (e) {
      print('Error loading building boundaries: $e');
    }
  }

  /// Called when the widget's configuration changes. Manages starting or stopping the polyline animation based on changes to the routePoints
  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePoints != oldWidget.routePoints &&
        widget.routePoints.isNotEmpty) {
      _startPolylineAnimation();
    } else if (widget.routePoints.isEmpty) {
      _stopPolylineAnimation();
      setState(() {
        animatedPoints.clear();
        animationIndex = 0;
        animationProgress = 0.0;
      });
    }
  }

  /// Starts the polyline animation by initializing animation variables and setting up a timer to update the animatedPoints
  void _startPolylineAnimation() {
    _stopPolylineAnimation(); // Stop previous animation
    animatedPoints.clear(); // Reset animation data
    animationIndex = 0;
    animationProgress = 0.0;
    animationTimer = Timer.periodic(const Duration(milliseconds: 14), (timer) {
      if (animationIndex < widget.routePoints.length - 1) {
        animationProgress += 0.7; // Increment animation progress
        if (animationProgress >= 1.0) {
          animationProgress = 0.0;
          animationIndex++;
        }
        setState(() {
          animatedPoints.clear();
          for (int i = 0; i < animationIndex; i++) {
            animatedPoints.add(widget.routePoints[i]);
          }
          if (animationIndex < widget.routePoints.length - 1) {
            final start = widget.routePoints[animationIndex];
            final end = widget.routePoints[animationIndex + 1];
            final lat = start.latitude +
                (end.latitude - start.latitude) * animationProgress;
            final lng = start.longitude +
                (end.longitude - start.longitude) * animationProgress;
            animatedPoints.add(LatLng(lat, lng));
          }
        });
      } else {
        _stopPolylineAnimation();
      }
    });
  }

  /// Cancels the animation timer, stopping the polyline animation.
  void _stopPolylineAnimation() {
    animationTimer?.cancel();
  }

  /// Stops the polyline animation and disposes of the widget
  @override
  void dispose() {
    _stopPolylineAnimation();
    super.dispose();
  }

  /// Builds the map widget with the FlutterMap and its children
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
            // onTap: _handleMapTap,
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
            if (!widget.routePoints.isNotEmpty)
              PolygonLayer(
                polygons: _buildingPolygons,
              ),
            if (!widget.routePoints.isNotEmpty)
              MarkerLayer(
                markers: [
                  ..._buildingMarkers,
                ],
              ),
            if (animatedPoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: animatedPoints,
                    strokeWidth: 10.0,
                    color: const Color.fromARGB(
                        100, 0, 0, 0), // Soft black shadow with transparency
                  ),
                  Polyline(
                    points: animatedPoints,
                    strokeWidth: 6.0,
                    color: const Color.fromRGBO(
                        54, 152, 244, 0.8), // Nice vivid blue with 80% opacity
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
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
          routePoints: [],
        ),
      ),
    );
  }
}
