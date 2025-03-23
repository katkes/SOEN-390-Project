// WaypointSelectionScreen handles user input for creating an itinerary.
// Users can select a start and destination, add stops, choose a transport mode,
// and confirm their route. Confirmed routes are displayed dynamically using RouteCards.
// The screen also integrates with the bottom navigation bar for seamless app navigation.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/services/building_info_api.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/route_card.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:soen_390/utils/route_display.dart' as display;
import 'package:soen_390/utils/route_utils.dart' as utils;
import 'package:http/http.dart' as http;

class WaypointSelectionScreen extends StatefulWidget {
  final IRouteService routeService;
  final GeocodingService geocodingService;
  final LocationService locationService;
  final String? initialDestination;
  final double? destinationLat;
  final double? destinationLng;

  const WaypointSelectionScreen({
    super.key,
    required this.routeService,
    required this.geocodingService,
    required this.locationService,
    this.initialDestination,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  WaypointSelectionScreenState createState() => WaypointSelectionScreenState();
}

class WaypointSelectionScreenState extends State<WaypointSelectionScreen> {
  final int _selectedIndex = 1;
  static const int _maxRoutes = 4;
  static const int _minRoutes = 2;
  bool isLoading = false;
  bool isCrossCampus = false;
  String? errorMessage;
  String? selectedMode;
  List<Map<String, dynamic>> confirmedRoutes = [];
  bool _locationsChanged =
      false; //adding boolean flag to track whether the locations have been updated.
  final Map<String, Map<String, List<RouteResult>>> _routeCache =
      {}; //cache for routes

  // Injected services for route and geocoding functionality
  late GoogleRouteService routeService;
  late GeocodingService geocodingService;
  late LocationService locationService;

  @override
  void initState() {
    super.initState();
    routeService = widget.routeService as GoogleRouteService;
    geocodingService = widget.geocodingService;
    locationService = widget.locationService;
  }

  void _handleShuttleBusSelection() {
    setState(() {
      selectedMode = "Shuttle Bus";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Shuttle Bus selected!")),
    );
  }

  bool _tryDisplayFromCache(String googleTransportMode, String waypointKey,
      List<String> waypoints, String transportMode) {
    if (!_locationsChanged &&
        _routeCache.containsKey(googleTransportMode) &&
        _routeCache[googleTransportMode]!.containsKey(waypointKey)) {
      print("Cache hit for $waypointKey using $googleTransportMode mode");
      final cachedRoutes = _routeCache[googleTransportMode]![waypointKey]!;

      // Routes are cached, filter and display
      print("Routes are cached for $googleTransportMode, filtering...");
      display.displayRoutes(
        context: context,
        updateRoutes: (routes) => setState(() => confirmedRoutes = routes),
        waypoints: waypoints,
        routes: cachedRoutes,
        transportMode: transportMode,
      );
      return true;
    }
    return false;
  }

// Main method with extracted helper methods
  void _handleRouteConfirmation(
      List<String> waypoints, String transportMode) async {
    // Early validation
    if (!_validateWaypoints(waypoints)) return;

    // Setup and cache checking
    final String googleTransportMode =
        utils.mapTransportModeToApiMode(transportMode);
    String waypointKey = "${waypoints.first}-${waypoints.last}";

    // Return early if route found in cache
    if (_tryDisplayFromCache(
        googleTransportMode, waypointKey, waypoints, transportMode)) {
      return;
    }

    // Handle transport mode changes
    _handleTransportModeChange(transportMode);

    // Update state before API call
    _setLoadingState(transportMode);

    try {
      // Fetch and display routes
      await _fetchAndDisplayRoutes(
          waypoints, googleTransportMode, transportMode);
    } catch (e) {
      _handleRouteError(e);
    }
  }

// Helper methods
  bool _validateWaypoints(List<String> waypoints) {
    if (waypoints.length < _minRoutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must have at least a start and destination.")),
      );
      return false;
    }
    return true;
  }

void _handleTransportModeChange(String transportMode) {
    if (selectedMode != transportMode) {
      _clearConfirmedRoutes();
      selectedMode = transportMode;
    }
  }

void _setLoadingState(String transportMode) {
    setState(() {
      isLoading = true;
      errorMessage = null;
      selectedMode = transportMode;
      _locationsChanged = false;
    });
}

  Future<void> _fetchAndDisplayRoutes(List<String> waypoints,
      String googleTransportMode, String transportMode) async {
    // Resolve start and end coordinates
    final coordinates = await _resolveCoordinates(waypoints);
    if (coordinates == null) return;

    final startPoint = coordinates['start']!;
    final endPoint = coordinates['end']!;

    // Get routes from service
    final routes = await routeService.getRoutes(from: startPoint, to: endPoint);

    // Check for cross-campus route
    isCrossCampus =
        GoogleRouteService.isRouteInterCampus(from: startPoint, to: endPoint);
    print("Route involves campus switch: $isCrossCampus");

    // Validate and process routes
    if (!_validateRoutes(routes, googleTransportMode)) return;
  
    // Get and cache the routes
    final topRoutes =
        _processAndCacheRoutes(routes, googleTransportMode, waypoints);
    if (topRoutes == null) return;

    // Update UI state
    if (!mounted) return;
    setState(() => _locationsChanged = false);

    // Display the routes
    _displayRoutesAndLogDetails(waypoints, topRoutes, transportMode);
  }

  Future<Map<String, LatLng>?> _resolveCoordinates(
      List<String> waypoints) async {
    final LatLng? startPoint =
        await geocodingService.getCoordinates(waypoints.first);
    LatLng? endPoint;

    if (widget.destinationLat != null && widget.destinationLng != null) {
      endPoint = LatLng(widget.destinationLat!, widget.destinationLng!);
    } else {
      endPoint = await geocodingService.getCoordinates(waypoints.last);
    }

    if (startPoint == null || endPoint == null) {
      throw Exception("Failed to resolve coordinates for waypoints");
    }

    return {'start': startPoint, 'end': endPoint};
  }

bool _validateRoutes(
      Map<String, List<RouteResult>> routes, String googleTransportMode) {
    if (routes.isEmpty ||
        !routes.containsKey(googleTransportMode) ||
        routes[googleTransportMode]!.isEmpty) {
      throw Exception("No routes found for the selected transport mode");
    }
    return true;
  }

List<RouteResult>? _processAndCacheRoutes(
      Map<String, List<RouteResult>> routes,
      String googleTransportMode,
      List<String> waypoints) {
    final selectedRoutes = routes[googleTransportMode]!;
    final topRoutes = selectedRoutes.take(_maxRoutes).toList();
  
    // Cache the routes
    if (!_routeCache.containsKey(googleTransportMode)) {
      _routeCache[googleTransportMode] = {};
    }
    String waypointKey = "${waypoints.first}-${waypoints.last}";
    _routeCache[googleTransportMode]![waypointKey] = selectedRoutes;
  
    return topRoutes;
  }

void _displayRoutesAndLogDetails(
      List<String> waypoints, List<RouteResult> routes, String transportMode) {
    display.displayRoutes(
      context: context,
      updateRoutes: (routes) => setState(() => confirmedRoutes = routes),
      waypoints: waypoints,
      routes: routes,
      transportMode: transportMode,
    );

    print("Final confirmed route: $waypoints, Mode: $transportMode");
    print(
        "Route details: ${routes.first.distance} meters, ${routes.first.duration} seconds");
  }

  void _handleRouteError(dynamic error) {
    if (!mounted) return;
  
    setState(() {
      isLoading = false;
      errorMessage = "Error finding route: ${error.toString()}";
    });
  
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage!)),
    );
  }

  void _setLocationChanged() {
    setState(() {
      _locationsChanged = true;
      _routeCache.clear();
    });
  }

//function to clear the confirmed routes list
  void _clearConfirmedRoutes() {
    setState(() {
      confirmedRoutes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff912338),
        title: const Text("Find my Way",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [Icon(Icons.more_vert, color: Colors.white)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LocationTransportSelector(
              locationService: widget.locationService,
              poiService: GooglePOIService(
                apiKey: dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '',
                httpService: HttpService(),
              ),
              poiFactory: PointOfInterestFactory(
                apiClient: GoogleMapsApiClient(
                  apiKey: dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '',
                  client: http.Client(),
                ),
              ),
              initialDestination: widget.initialDestination,
              onConfirmRoute: _handleRouteConfirmation,
              onLocationChanged: _setLocationChanged,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleShuttleBusSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text("Use Shuttle Bus?",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true, // Ensures it only takes needed space
              physics:
                  const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
              itemCount: confirmedRoutes.length > _maxRoutes
                  ? _maxRoutes
                  : confirmedRoutes.length,
              itemBuilder: (context, index) {
                final route = confirmedRoutes[index];
                return RouteCard(
                  title: route["title"],
                  timeRange: route["timeRange"],
                  duration: route["duration"],
                  description: route["description"],
                  icons: route["icons"],
                  routeData: route["routeData"],
                  isCrossCampus: isCrossCampus,
                  onCardTapped: () {
                    Navigator.pop(context, route["routeData"]);
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index != 1) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
