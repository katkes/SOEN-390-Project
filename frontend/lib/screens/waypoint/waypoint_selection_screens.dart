// WaypointSelectionScreen handles user input for creating an itinerary.
// Users can select a start and destination, add stops, choose a transport mode,
// and confirm their route. Confirmed routes are displayed dynamically using RouteCards.
// The screen also integrates with the bottom navigation bar for seamless app navigation.

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:soen_390/widgets/route_card.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:soen_390/utils/route_display.dart' as display;
import 'package:soen_390/utils/route_utils.dart' as utils;

class WaypointSelectionScreen extends StatefulWidget {
  final IRouteService routeService;
  final GeocodingService geocodingService;
  final LocationService locationService;

  const WaypointSelectionScreen(
      {super.key,
      required this.routeService,
      required this.geocodingService,
      required this.locationService});

  @override
  WaypointSelectionScreenState createState() => WaypointSelectionScreenState();
}

class WaypointSelectionScreenState extends State<WaypointSelectionScreen> {
  final int _selectedIndex = 1;
  static const int _maxRoutes = 4;
  static const int _minROutes = 2;
  bool isLoading = false;
  String? errorMessage;
  String? selectedMode;
  List<Map<String, dynamic>> confirmedRoutes = [];
  List<RouteResult> fetchedRoutes = [];
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

  void _handleRouteConfirmation(
      List<String> waypoints, String transportMode) async {
    if (waypoints.length < _minROutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must have at least a start and destination.")),
      );
      return;
    }

    final String googleTransportMode =
        utils.mapTransportModeToApiMode(transportMode);
    String waypointKey = "${waypoints.first}-${waypoints.last}";

    // Check cache with consistent keys
    if (!_locationsChanged &&
        _routeCache.containsKey(googleTransportMode) &&
        _routeCache[googleTransportMode]!.containsKey(waypointKey)) {
      print("Cache hit for $waypointKey using $googleTransportMode mode");
      // Routes are cached, filter and display
      print("Routes are cached for $googleTransportMode, filtering...");
      final cachedRoutes = _routeCache[googleTransportMode]![waypointKey]!;
      display.displayRoutes(
        context: context,
        confirmedRoutes: confirmedRoutes,
        updateRoutes: (routes) => setState(() => confirmedRoutes = routes),
        waypoints: waypoints,
        routes: cachedRoutes,
        transportMode: transportMode,
      ); // Display cached routes
      return;
    }

    if (selectedMode != transportMode) {
      _clearConfirmedRoutes(); // Clear routes when mode changes
      selectedMode = transportMode;
      // _routeCache.clear();
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      selectedMode = transportMode;
      _locationsChanged = false;
    });

    try {
      // Convert location names to coordinates using geocoding service
      final LatLng? startPoint =
          await geocodingService.getCoordinates(waypoints.first);
      final LatLng? endPoint =
          await geocodingService.getCoordinates(waypoints.last);

      if (startPoint == null || endPoint == null) {
        throw Exception("Could not find coordinates for one or more locations");
      }

      // Fetch routes for the selected transport mode
      final routes = await routeService.getRoutes(
        from: startPoint,
        to: endPoint,
      );

      if (routes.isEmpty ||
          !routes.containsKey(googleTransportMode) ||
          routes[googleTransportMode]!.isEmpty) {
        throw Exception("No routes found for the selected transport mode");
      }

      // Get the top 4 routes for the selected transport mode
      final selectedRoutes = routes[googleTransportMode]!;
      final topRoutes =
          selectedRoutes.take(_maxRoutes).toList(); // Get the top 4 routes

      // Store routes in cache
      if (!_routeCache.containsKey(googleTransportMode)) {
        _routeCache[googleTransportMode] = {};
      }
      _routeCache[googleTransportMode]![waypointKey] = selectedRoutes;
      if (!mounted) return;

      setState(() {
        _locationsChanged = false;
      });

      // Display the routes
      display.displayRoutes(
        context: context,
        confirmedRoutes: confirmedRoutes,
        updateRoutes: (routes) => setState(() => confirmedRoutes = routes),
        waypoints: waypoints,
        routes: topRoutes,
        transportMode: transportMode,
      );

      print("Final confirmed route: $waypoints, Mode: $transportMode");
      print(
          "Route details: ${topRoutes.first.distance} meters, ${topRoutes.first.duration} seconds");
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Error finding route: ${e.toString()}";
      });

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    }
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
      body: Column(
        children: [
          LocationTransportSelector(
            onConfirmRoute: _handleRouteConfirmation,
            onLocationChanged: _setLocationChanged,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
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
                  onCardTapped: () {
                
                 

                  Navigator.pop(context, route["routeData"]);
                 
                },
                );
              },
            ),
          ),
        ],
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
