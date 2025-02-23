import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http; // Import http

// This widget displays a map with markers at specific locations (SGW and Loyola campuses).
class MapWidget extends StatefulWidget {
  // Rename to MapWidget
  final LatLng location;
  final http.Client httpClient; // Add httpClient

  const MapWidget(
      {super.key, required this.location, required this.httpClient});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  // Rename State
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    // Update type
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
    }
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
  final http.Client httpClient; // Receive injected client
  final LatLng location;

  const MyPage({required this.httpClient, required this.location, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Or use a Stack if you need positioning
        child: MapWidget(
          location: location,
          httpClient: httpClient, // Pass the client down
        ),
      ),
    );
  }
}
