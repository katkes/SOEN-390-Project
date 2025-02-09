import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapRectangle extends StatefulWidget {
  final LatLng location;

  const MapRectangle({super.key, required this.location});

  @override
  State<MapRectangle> createState() => _MapRectangleState();
}

class _MapRectangleState extends State<MapRectangle> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(MapRectangle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 5,
      left: 10,
      right: 10,
      child: Center(
        child: SizedBox(
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
        ),
      ),
    );
  }
}
