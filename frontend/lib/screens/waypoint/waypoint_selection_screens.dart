// WaypointSelectionScreen handles user input for creating an itinerary.
// Users can select a start and destination, add stops, choose a transport mode,
// and confirm their route. Confirmed routes are displayed dynamically using RouteCards.
// The screen also integrates with the bottom navigation bar for seamless app navigation.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen_390/services/google_maps_api_client.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/services/location_updater.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/utils/campus_route_checker.dart';
import 'package:soen_390/utils/route_cache_manager.dart';
import 'package:soen_390/utils/route_fetcher.dart';
import 'package:soen_390/widgets/location_transport_selector.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/route_card.dart';
import 'package:soen_390/services/google_route_service.dart';
import 'package:soen_390/services/geocoding_service.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:soen_390/utils/route_display.dart' as display;
import 'package:soen_390/utils/route_utils.dart' as utils;
import "package:soen_390/screens/indoor_accessibility/indoor_accessibility_preference.dart";
import 'package:soen_390/utils/waypoint_validator.dart';

class WaypointSelectionScreen extends StatefulWidget {
  final IRouteService routeService;
  final GeocodingService geocodingService;
  final LocationService locationService;
  final String? initialDestination;
  final double? destinationLat;
  final double? destinationLng;
  final CampusRouteChecker campusRouteChecker;
  final WaypointValidator waypointValidator;
  final RouteCacheManager routeCacheManager;

  const WaypointSelectionScreen({
    super.key,
    required this.routeService,
    required this.geocodingService,
    required this.locationService,
    required this.campusRouteChecker,
    required this.waypointValidator,
    required this.routeCacheManager,
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

  // Injected services for route and geocoding functionality
  late GoogleRouteService routeService;
  late GeocodingService geocodingService;
  late LocationService locationService;
  late RouteCacheManager _routeCacheManager;

  @override
  void initState() {
    super.initState();
    routeService = widget.routeService as GoogleRouteService;
    geocodingService = widget.geocodingService;
    locationService = widget.locationService;
    _routeCacheManager = widget.routeCacheManager;
  }

  bool _tryDisplayFromCache(String googleTransportMode, String waypointKey,
      List<String> waypoints, String transportMode) {
    if (!_locationsChanged &&
        _routeCacheManager.hasCached(googleTransportMode, waypointKey)) {
      final cachedRoutes =
          _routeCacheManager.getCached(googleTransportMode, waypointKey)!;

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
  void _handleRouteConfirmation(List<String> waypoints, String transportMode) {
    if (!widget.waypointValidator.validate(context, waypoints, _minRoutes)) {
      return;
    }

    final String googleTransportMode =
        utils.mapTransportModeToApiMode(transportMode);
    final String waypointKey = "${waypoints.first}-${waypoints.last}";

    if (_tryDisplayFromCache(
        googleTransportMode, waypointKey, waypoints, transportMode)) {
      return;
    }

    _prepareAndFetchRoute(waypoints, transportMode);
  }

  void _prepareAndFetchRoute(
      List<String> waypoints, String transportMode) async {
    _handleTransportModeChange(transportMode);
    _setLoadingState(transportMode);

    try {
      final fetcher = RouteFetcher(
        context: context,
        routeService: routeService,
        geocodingService: geocodingService,
        locationService: locationService,
        campusRouteChecker: widget.campusRouteChecker,
        overrideDestLat: widget.destinationLat,
        overrideDestLng: widget.destinationLng,
        updateRoutes: (routes) => setState(() => confirmedRoutes = routes),
        setCrossCampus: (value) => isCrossCampus = value,
        cacheManager: _routeCacheManager,
      );

      final topRoutes = await fetcher.fetchRoutes(waypoints,
          utils.mapTransportModeToApiMode(transportMode), transportMode);

      if (topRoutes == null) return;

      setState(() => _locationsChanged = false);

      fetcher.displayRoutes(waypoints, topRoutes, transportMode);
    } catch (e) {
      _handleRouteError(e);
    }
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
      _routeCacheManager.clear();
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
        actions: [
          //const Icon(Icons.more_vert, color: Colors.white),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8), // Adjust padding as needed
            child: SizedBox(
              height: 40, // Control button height
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IndoorAccessibilityPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White button for contrast
                  foregroundColor: const Color(0xff912338), // Text color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded edges
                  ),
                ),
                child: const Text(
                  'Specify Disability',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LocationTransportSelector(
              locationService: widget.locationService,
              poiService: GooglePOIService(
                apiKey: dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '',
                httpClient: HttpService(),
              ),
              poiFactory: PointOfInterestFactory(
                apiClient: GoogleMapsApiClient(
                  apiKey: dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '',
                  httpClient: HttpService(),
                ),
              ),
              initialDestination: widget.initialDestination,
              onConfirmRoute: _handleRouteConfirmation,
              onLocationChanged: _setLocationChanged,
              locationUpdater: LocationUpdater(locationService),
            ),
            const SizedBox(height: 10),
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
