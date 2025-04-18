import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/services/google_maps_api_client.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:soen_390/services/interfaces/http_client_interface.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:soen_390/utils/marker_tap_handler.dart';
import 'package:soen_390/widgets/building_popup.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:soen_390/widgets/indoor_navigation_button.dart';
import 'package:http/http.dart' as http;
// import "package:soen_390/providers/theme_provider.dart";

/// A widget that displays an interactive map with routing functionality.
///
/// The map allows users to visualize locations, interact with markers,
/// and calculate routes between two selected points using the injected `IRouteService`.
class MapWidget extends StatefulWidget {
  //final LocationServiceWithNoInjection locationService = LocationServiceWithNoInjection.instance;

  /// The initial location where the map is centered.
  final LatLng location;

  ///The initial location where the user is.

  final LatLng userLocation;

  /// The HTTP client used for network requests related to map tiles.
  final IHttpClient httpClient;

  /// The route service responsible for fetching route data.
  final IRouteService routeService;

  final GoogleMapsApiClient mapsApiClient;
  final BuildingPopUps buildingPopUps;

  /// A list of `LatLng` points representing the route path.
  final List<LatLng> routePoints;
  final Function(RouteResult)? onRouteSelected;

  /// Creates an instance of `MapWidget` with required dependencies.
  ///
  /// - [location]: The initial `LatLng` location for the map.
  /// - [httpClient]: The HTTP client used for loading map tiles.
  /// - [routeService]: The service used to fetch navigation routes.
  const MapWidget({
    super.key,
    required this.location,
    required this.userLocation,
    required this.httpClient,
    required this.routeService,
    required this.mapsApiClient,
    required this.buildingPopUps,
    required this.routePoints,
    this.onRouteSelected,
  });

  // void selectMarker(LatLng location){
  //   MapWidgetState? state = _mapWidgetKey.currentState;

  //   if (state!= null) {
  //     state.selectMarker(location);
  //   }

  // }

  // final GlobalKey<MapWidgetState>
  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  late MapController _mapController;
  List<Marker> _buildingMarkers = [];
  List<Polygon> _buildingPolygons = [];
  // ignore: unused_field
  String? _selectedBuildingName;
  // ignore: unused_field
  String? _selectedBuildingAddress;

  /// The starting location for route calculation.
  late LatLng from;

  /// The destination location for route calculation.
  late LatLng to;

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

  MarkerTapHandler get markerTapHandler => _markerTapHandler;

  void selectMarker(LatLng location) {
    // Update selected marker in MapService
    _mapService.selectMarker(location);

    // Reload markers to reflect the change
    _loadBuildingLocations();

    // Move map to the selected location
    _mapController.move(location, 17.0);
  }

  List<LatLng> animatedPoints = [];
  int animationIndex = 0;
  Timer? animationTimer;
  Timer? zoomAnimationTimer;
  double animationProgress = 0.0; // Track progress between points

  @override
  void initState() {
    super.initState();
    //widget.onRoutePointsChanged(routePoints); // this line crashes the map
    _mapController = MapController();
    _mapService = MapService();

    _mapService.onMarkerCleared = () {
      // Use onMarkerCleared
      setState(() {
        _loadBuildingLocations();
      });
    };
    _markerTapHandler = MarkerTapHandler(
      onBuildingInfoUpdated: (name, address) {
        setState(() {
          _selectedBuildingName = name;
          _selectedBuildingAddress = address;
        });
      },
      mapController: _mapController,
      buildingPopUps: widget.buildingPopUps,
      onRouteSelected: widget.onRouteSelected,
    );
    _loadBuildingLocations();
    _loadBuildingBoundaries();
    from = widget.location;
    to = LatLng(
        widget.location.latitude + 0.005, widget.location.longitude + 0.005);
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
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
      from = widget.location;
    }
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

  static const double zoomLevelMax = 19.0;
  static const double zoomLevelIncrease = 2.5;
  static const double zoomDurationMillis = 2500.0;
  static const double polylineAnimationProgressIncrement = 0.7;
  static const int polylineAnimationIntervalMillis = 14;
  static const int zoomAnimationIntervalMillis = 16;

  static const double distanceZoomLevelFar = 20000;
  static const double distanceZoomLevelMediumFar = 10000;
  static const double distanceZoomLevelMedium = 5000;
  static const double distanceZoomLevelClose = 1000;
  static const double distanceZoomLevelVeryClose = 500;

  static const double zoomLevelFar = 10.0;
  static const double zoomLevelMediumFar = 11.5;
  static const double zoomLevelMedium = 13.0;
  static const double zoomLevelClose = 14.5;
  static const double zoomLevelVeryClose = 15.5;
  static const double zoomLevelDefault = 17.0;

  void _startPolylineAnimation() {
    _stopPolylineAnimation(); // Stop any previous animation
    resetAnimationData();

    if (widget.routePoints.isEmpty) return;

    final routeCenter = _calculateRouteCenter(widget.routePoints);
    final totalDistance = _calculateTotalDistance(widget.routePoints);
    final targetZoomLevel = _determineTargetZoomLevel(totalDistance);
    final startingZoomLevel =
        min(zoomLevelMax, targetZoomLevel + zoomLevelIncrease);

    _setInitialMapView(routeCenter, startingZoomLevel);
    _animateZoom(routeCenter, startingZoomLevel, targetZoomLevel);
    _animatePolylinePath();
  }

  void resetAnimationData() {
    animatedPoints.clear();
    animationIndex = 0;
    animationProgress = 0.0;
  }

  LatLng _calculateRouteCenter(List<LatLng> routePoints) {
    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;

    for (var point in routePoints) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  double _calculateTotalDistance(List<LatLng> routePoints) {
    const Distance distanceCalc = Distance();
    double totalDistance = 0.0;

    for (int i = 0; i < routePoints.length - 1; i++) {
      totalDistance += distanceCalc(routePoints[i], routePoints[i + 1]);
    }

    return totalDistance;
  }

  double _determineTargetZoomLevel(double totalDistance) {
    if (totalDistance > distanceZoomLevelFar) {
      return zoomLevelFar;
    } else if (totalDistance > distanceZoomLevelMediumFar) {
      return zoomLevelMediumFar;
    } else if (totalDistance > distanceZoomLevelMedium) {
      return zoomLevelMedium;
    } else if (totalDistance > distanceZoomLevelClose) {
      return zoomLevelClose;
    } else if (totalDistance > distanceZoomLevelVeryClose) {
      return zoomLevelVeryClose;
    } else {
      return zoomLevelDefault;
    }
  }

  void _setInitialMapView(LatLng routeCenter, double startingZoomLevel) {
    _mapController.move(routeCenter, startingZoomLevel);
  }

  void _animateZoom(
      LatLng routeCenter, double startingZoomLevel, double targetZoomLevel) {
    final zoomDuration = Duration(milliseconds: zoomDurationMillis.toInt());
    final startTime = DateTime.now();

    zoomAnimationTimer = Timer.periodic(
        const Duration(milliseconds: zoomAnimationIntervalMillis), (zoomTimer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final progress = min(1.0, elapsed / zoomDuration.inMilliseconds);

      final eased = 1 - pow(1 - progress, 2).toDouble();
      final currentZoom =
          startingZoomLevel - (startingZoomLevel - targetZoomLevel) * eased;

      _mapController.move(routeCenter, currentZoom);

      if (progress >= 1.0) {
        zoomTimer.cancel();
        zoomAnimationTimer = null;
      }
    });
  }

  void _animatePolylinePath() {
    animationTimer = Timer.periodic(
        const Duration(milliseconds: polylineAnimationIntervalMillis), (timer) {
      if (animationIndex < widget.routePoints.length - 1) {
        _updatePolylineAnimation();
      } else {
        _stopPolylineAnimation();
      }
    });
  }

  void _updatePolylineAnimation() {
    animationProgress +=
        polylineAnimationProgressIncrement; // Increment animation progress
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
  }

  /// Cancels the animation timer, stopping the polyline animation.
  /// This method is called when the widget is disposed or when the route points change.
  void _stopPolylineAnimation() {
    animationTimer?.cancel();
    zoomAnimationTimer?.cancel();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDark
        ? "https://api.maptiler.com/maps/streets-v2-dark/{z}/{x}/{y}.png?key=dNrRaCzvW960GhB3n3bW"
        : "https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=dNrRaCzvW960GhB3n3bW";

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.location,
                initialZoom: 17.0,
                minZoom: 11.0,
                maxZoom: 20.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: tileUrl,
                  additionalOptions: const {},
                  tileProvider: NetworkTileProvider(
                    httpClient: widget.httpClient is HttpService
                        ? (widget.httpClient as HttpService).client
                        : http.Client(), // fallback in test/mock mode
                  ),
                ),
                AnimatedLocationMarkerLayer(
                  position: LocationMarkerPosition(
                    latitude: widget.userLocation.latitude,
                    longitude: widget.userLocation.longitude,
                    accuracy: 50,
                  ),
                  style: const LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    markerSize: Size(35, 35),
                    markerDirection: MarkerDirection.heading,
                    accuracyCircleColor: Color.fromARGB(78, 33, 149, 243),
                  ),
                  moveAnimationDuration: const Duration(milliseconds: 500),
                  moveAnimationCurve: Curves.fastOutSlowIn,
                  rotateAnimationDuration: const Duration(milliseconds: 300),
                  rotateAnimationCurve: Curves.easeInOut,
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
                        color: const Color.fromARGB(100, 0, 0,
                            0), // Soft black shadow with transparency
                      ),
                      Polyline(
                        points: animatedPoints,
                        strokeWidth: 6.0,
                        color: const Color.fromRGBO(54, 152, 244,
                            0.8), // Nice vivid blue with 80% opacity
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 21,
          child: IndoorNavigationButton(
            onPressed: _centerMapOnUser,
            key: const Key('indoor-navigation-buttons'),
          ),
        ),
      ],
    );
  }

  void _centerMapOnUser() {
    _mapController.move(
      widget.userLocation,
      17.0,
    );
  }
}

/// Example usage of `MapWidget` inside a `MyPage` scaffold.
class MyPage extends StatelessWidget {
  /// The injected route service for fetching navigation routes.
  final IRouteService routeService;

  /// The injected HTTP client for loading map tiles.
  final IHttpClient httpClient;

  /// The initial location for the map.

  final LatLng location;
  final LatLng userLocation;
  final GoogleMapsApiClient mapsApiClient;
  final BuildingPopUps buildingPopUps;

  /// Creates a `MyPage` instance with necessary dependencies.
  const MyPage({
    required this.httpClient,
    required this.location,
    required this.userLocation,
    required this.routeService,
    required this.mapsApiClient,
    required this.buildingPopUps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mapsApiClient = GoogleMapsApiClient(
      apiKey: "GOOGLE_MAPS_API_KEY",
      httpClient: httpClient,
    );

    final buildingPopUps = BuildingPopUps(
      mapsApiClient: mapsApiClient,
    );
    return Scaffold(
      body: Center(
        child: MapWidget(
          location: location,
          userLocation: userLocation,
          httpClient: httpClient,
          routeService: routeService,
          mapsApiClient: mapsApiClient,
          buildingPopUps: buildingPopUps,
          routePoints: const [],
        ),
      ),
    );
  }
}
