// WaypointSelectionScreen handles user input for creating an itinerary.
// Users can select a start and destination, add stops, choose a transport mode,
// and confirm their route. Confirmed routes are displayed dynamically using RouteCards.
// The screen also integrates with the bottom navigation bar for seamless app navigation.

import 'package:flutter/material.dart';
import '../../widgets/location_transport_selector.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/route_card.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';

class WaypointSelectionScreen extends StatefulWidget {
  final IRouteService routeService; 
  final GeocodingService geocodingService;
  final LocationService locationService;

  WaypointSelectionScreen({super.key, required this.routeService, required this.geocodingService, required this.locationService});
  

  @override
  WaypointSelectionScreenState createState() => WaypointSelectionScreenState();
}

class WaypointSelectionScreenState extends State<WaypointSelectionScreen> {
  final int _selectedIndex = 1;
  bool isLoading = false;
  String? errorMessage;
  String? selectedMode;
  List<Map<String, dynamic>> confirmedRoutes = [];
  List<RouteResult> fetchedRoutes = [];
  bool _locationsChanged = false; //adding boolean flag to track whether the locations have been updated.
  final Map<String, Map<String, List<RouteResult>>> _routeCache = {}; //cache for routes

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

  void _handleRouteConfirmation(List<String> waypoints, String transportMode) async {
    if (waypoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must have at least a start and destination.")),
      );
      return;
    }

    final String googleTransportMode = _mapTransportModeToApiMode(transportMode);
    String waypointKey = "${waypoints.first}-${waypoints.last}";

    // Check cache with consistent keys
    if (!_locationsChanged &&
        _routeCache.containsKey(googleTransportMode) &&
        _routeCache[googleTransportMode]!.containsKey(waypointKey)) {
          print("Cache hit for $waypointKey using $googleTransportMode mode");
        // Routes are cached, filter and display
        print("Routes are cached for $googleTransportMode, filtering...");
        final cachedRoutes = _routeCache[googleTransportMode]![waypointKey]!;
        _displayRoutes(cachedRoutes, transportMode, waypoints); // Display cached routes
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
      final LatLng? startPoint = await geocodingService.getCoordinates(waypoints.first);
      final LatLng? endPoint = await geocodingService.getCoordinates(waypoints.last);

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
      final topRoutes = selectedRoutes.take(4).toList(); // Get the top 4 routes
      
      // Store routes in cache
      if (!_routeCache.containsKey(googleTransportMode)) {
        _routeCache[googleTransportMode] = {};
      }
      _routeCache[googleTransportMode]![waypointKey] = selectedRoutes;

      setState(() {
  _locationsChanged = false;
});
      
      // Display the routes
      _displayRoutes(selectedRoutes, transportMode, waypoints);

      print("Final confirmed route: $waypoints, Mode: $transportMode");
      print("Route details: ${topRoutes.first.distance} meters, ${topRoutes.first.duration} seconds");
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error finding route: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    }
}
void _setLocationChanged(){
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
// Helper function to display routes
void _displayRoutes(List<RouteResult> routes, String transportMode, List<String> waypoints) {
     setState(() {
         confirmedRoutes = routes.map((route) {
             return {
                 "title": "${_shortenAddress(waypoints.first)} to ${_shortenAddress(waypoints.last)}",
                 "timeRange": _formatTimeRange(route.duration),
                 "duration": _formatDuration(route.duration),
                 "description": waypoints.map((waypoint) => _shortenAddress(waypoint)).join(" → "),
                 "icons": _getIconsForTransport(transportMode),
                 "routeData": route,
             };
         }).toList();
         isLoading = false;
     });
}

  String _shortenAddress(String address) {
    //Remove any components like province or country.
    // We'll assume addresses have a format like "Building, Street, City, Province, Country"
    final parts = address.split(", ");
    if (parts.length > 2) {
      // Remove last 2 parts (e.g., Province, Country)
      return parts.take(parts.length - 2).join(", ");
    }
    return address; // Return as-is if it's already short.
  }

  List<IconData> _getIconsForTransport(String mode) {
    switch (mode) {
      case "Car":
        return [Icons.directions_car];
      case "Bike":
        return [Icons.directions_bike];
      case "Train or Bus":
        return [Icons.train];
      case "Walk":
        return [Icons.directions_walk];
      default:
        return [Icons.help_outline];
    }
  }

  String _mapTransportModeToApiMode(String uiMode) {
    switch (uiMode) {
      case "Car":
        return "driving";
      case "Bike":
        return "bicycling";
      case "Train or Bus":
        return "transit";
      case "Walk":
        return "walking";
      default:
        return "transit";
    }
  }

  // Helper method to format duration in seconds to human-readable format
  String _formatDuration(double seconds) {
    final int minutes = (seconds / 60).round();
    if (minutes < 60) {
      return "$minutes min";
    } else {
      final int hours = (minutes / 60).floor();
      final int remainingMinutes = minutes % 60;
      return "$hours h $remainingMinutes min";
    }
  }

  // Helper method to format time range based on current time and duration
  String _formatTimeRange(double seconds) {
    final now = DateTime.now();
    final arrival = now.add(Duration(seconds: seconds.round()));

    String formatTime(DateTime time) {
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final period = time.hour >= 12 ? "PM" : "AM";
      return "${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period";
    }

    return "${formatTime(now)} - ${formatTime(arrival)}";
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
          LocationTransportSelector(onConfirmRoute: _handleRouteConfirmation, onLocationChanged: _setLocationChanged,),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: confirmedRoutes.length,
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
                    // When card is tapped, navigate back to the main screen (WaypointSelectionScreen)
                    Navigator.pop(context);
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
