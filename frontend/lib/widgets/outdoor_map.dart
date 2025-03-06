import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/interfaces/route_service_interface.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/services/map_service.dart';
import 'package:soen_390/utils/marker_tap_handler.dart';
import '../services/building_info_api.dart';
import "package:soen_390/utils/location_service.dart";
import "package:geolocator/geolocator.dart";
import "package:soen_390/widgets/user_location_marker.dart";

/// A widget that displays an interactive map with routing functionality.
///
/// The map allows users to visualize locations, interact with markers,
/// and calculate routes between two selected points using the injected `IRouteService`.
class MapWidget extends StatefulWidget {

  //final LocationServiceWithNoInjection locationService = LocationServiceWithNoInjection.instance;

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
  ///
  /// removed const due to issues - Arnab
  const MapWidget(
      {super.key,
      required this.location,
      required this.httpClient,
      required this.routeService,
      required this.mapsApiClient,
      required this.buildingPopUps});

  @override
  State<MapWidget> createState() => _MapWidgetState();
} //end of class


class _MapWidgetState extends State<MapWidget> {

  LocationService locationService = LocationService.instance;

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

  ///
  late MapService _mapService;

  ///
  late MarkerTapHandler _markerTapHandler;

  ///Initializing the widget with _mapController, _mapService, _markerTapHandler, and loads initial functions
  @override
  void initState() {
    super.initState();
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

    from = widget.location;
    to = LatLng(
        widget.location.latitude + 0.005, widget.location.longitude + 0.005);
    _fetchRoute();
  }

  /// Updates the widget when the location changes
  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
      from = widget.location;
      _fetchRoute();
    }
  }

  /// Loads the building locations from the map service
  Future<void> _loadBuildingLocations() async {
    try {
      final markers = await _mapService
          .loadBuildingMarkers((lat, lon, name, address, tapPosition) {
        _markerTapHandler.onMarkerTapped(
            lat, lon, name, address, tapPosition, context);
      });

       Position p = await locationService.getCurrentLocationAccurately();

      setState(() {
        _buildingMarkers = markers;
        //this is the user's current location. Add this through the "getCurrentLocation" function
        _buildingMarkers.add(  Marker(
            point: LatLng(p.latitude, p.longitude), //replace with current location longitude and latitude
            width: 80,
            height: 80,
            child: const Icon(
              Icons.location_pin,
              color: Colors.blue,
              size: 40),
        )
        );
      });
    } catch (e) {
      print('Error loading building markers: $e');
    }
  }

  //DEPRICATED
  //function to periodically update the current location of the user on the map.
  // void updateCurrentLocationMarker() {
  //  listen to stream
  //  Everytime a new position event comes up, remove the last marker and add a new one corresponding to the new location.
  // }

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
            onTap: _handleMapTap,
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
            PolygonLayer(
              polygons: _buildingPolygons,
            ),
            MarkerLayer(
              markers: [
                ..._buildingMarkers,
              ],
            ),
            CurrentLocationWidget(),
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
} //end of _MapWidgetState class

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
