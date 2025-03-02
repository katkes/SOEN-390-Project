// WaypointSelectionScreen handles user input for creating an itinerary.
// Users can select a start and destination, add stops, choose a transport mode,
// and confirm their route. Confirmed routes are displayed dynamically using RouteCards.
// The screen also integrates with the bottom navigation bar for seamless app navigation.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../widgets/location_transport_selector.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/route_card.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/building_to_coordinates.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';

class WaypointSelectionScreen extends StatefulWidget {
  const WaypointSelectionScreen({super.key});

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

  // Injected services for route and geocoding functionality
  late GoogleRouteService routeService;
  late GeocodingService geocodingService;
  late LocationService locationService;

  @override
  void initState() {
    super.initState();

    final locationService =
        LocationService(geolocator: GeolocatorPlatform.instance);
    final httpService = HttpService();

    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print("ERROR: Missing API Key in .env file!");
      return;
    }

    routeService = GoogleRouteService(
      locationService: locationService,
      httpService: httpService,
      apiKey: apiKey,
    );

    geocodingService = GeocodingService(
      httpService: httpService,
      apiKey: apiKey,
    );
  }

  void _handleRouteConfirmation(
      List<String> waypoints, String transportMode) async {
    if (waypoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must have at least a start and destination.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      selectedMode = transportMode;
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

      // Map our UI transport mode to Google API transport mode
      final String googleTransportMode =
          _mapTransportModeToApiMode(transportMode);

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

      // Add the routes to the confirmed routes list
      setState(() {
        confirmedRoutes = topRoutes.map((route) {
          return {
            "title":
                "${_shortenAddress(waypoints.first)} to ${_shortenAddress(waypoints.last)}",
            "timeRange": _formatTimeRange(route.duration),
            "duration": _formatDuration(route.duration),
            "description": waypoints
                .map((waypoint) => _shortenAddress(waypoint))
                .join(" → "),
            "icons": _getIconsForTransport(transportMode),
            "routeData": route, // Store the actual route data for future use
          };
        }).toList();
        isLoading = false;
      });

      print("Final confirmed route: $waypoints, Mode: $transportMode");
      print(
          "Route details: ${topRoutes.first.distance} meters, ${topRoutes.first.duration} seconds");
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
          LocationTransportSelector(onConfirmRoute: _handleRouteConfirmation),
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
