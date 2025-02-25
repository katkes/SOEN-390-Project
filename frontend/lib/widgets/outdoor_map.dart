import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:soen_390/services/interfaces/route_service_interface.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http; // Import http

// This widget displays a map with markers at specific locations (SGW and Loyola campuses).
class MapWidget extends StatefulWidget {
  final LatLng location;
  final http.Client httpClient;
  final IRouteService routeService; // More abstract 

  const MapWidget({
    super.key,
    required this.location,
    required this.httpClient,
    required this.routeService, // Accept service as parameter
  });
  @override
  State<MapWidget> createState() => _MapWidgetState();
}


class _MapWidgetState extends State<MapWidget> {
  // Rename State
  late MapController _mapController;

  late LatLng from;
  late LatLng to;

  List<LatLng> routePoints = [];
  double distance = 0.0;
  double duration = 0.0;

  // Used to alternate taps between updating [from] and [to].
  bool isPairly = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    from = widget.location;
    to = LatLng(
        widget.location.latitude + 0.005, widget.location.longitude + 0.005);
    _getRoute();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    // Update type
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
    }
  }

Future<void> _getRoute() async {
    final routeResult = await widget.routeService.getRoute(from: from, to: to);
    if (routeResult == null) return;

    setState(() {
      distance = routeResult.distance;
      duration = routeResult.duration;
      routePoints = routeResult.routePoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox( 
      // Remove Positioned, use SizedBox directly
      width: 460,
      height: 570,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.location,
            initialZoom: 14.0,
            minZoom: 11.0,
            maxZoom: 17.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              additionalOptions: const {}, // Add this line
              tileProvider: NetworkTileProvider(
                  httpClient: widget.httpClient), // Pass httpClient here!
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 4.0,
                  color: Colors.red,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
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
                Marker(
                  point: from,
                  width: 40.0,
                  height: 40.0,
                  child: const Icon(Icons.location_pin,
                      color: Colors.blue, size: 40.0),
                ),
                Marker(
                  point: to,
                  width: 40.0,
                  height: 40.0,
                  child: const Icon(Icons.location_pin,
                      color: Colors.green, size: 40.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// How to use it:
class MyPage extends StatelessWidget {
  final IRouteService routeService; // Accept an abstract service
  final http.Client httpClient;
  final LatLng location;

  const MyPage({
    required this.httpClient,
    required this.location,
    required this.routeService, // Inject any IRouteService implementation
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MapWidget(
          location: location,
          httpClient: httpClient,
          routeService: routeService, // Use abstract interface
        ),
      ),
    );
  }
}

