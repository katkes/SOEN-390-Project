import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import 'package:soen_390/services/route_service.dart';

class MapRectangle extends StatefulWidget {
  final LatLng location;

  const MapRectangle({super.key, required this.location});

  @override
  State<MapRectangle> createState() => _MapRectangleState();
}

class _MapRectangleState extends State<MapRectangle> {
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
  void didUpdateWidget(MapRectangle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _mapController.move(widget.location, 17.0);
    }
  }

  Future<void> _getRoute() async {
    final result = await getRouteFromCoordinates(from: from, to: to);
    if (result != null) {
      setState(() {
        distance = result.distance;
        duration = result.duration;
        routePoints = result.routePoints;
      });
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
                onTap: (_, point) {
                  // Alternate between setting [from] and [to] on tap.
                  if (isPairly) {
                    to = point;
                  } else {
                    from = point;
                  }
                  isPairly = !isPairly;
                  _getRoute();
                },
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
                    if (routePoints.isNotEmpty)
                      Marker(
                        rotate: true,
                        width: 80.0,
                        height: 30.0,
                        point: routePoints[
                            math.max(0, (routePoints.length / 2).floor())],
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${distance.toStringAsFixed(2)} m',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
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
