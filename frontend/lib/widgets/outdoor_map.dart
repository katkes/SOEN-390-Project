import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapRectangle extends StatelessWidget {
  const MapRectangle({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 25,
      left: 20,
      right: 20,
      child: Center(
        child: SizedBox(
          width: 400,
          height: 600,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(45.5017, -73.5673),
                initialZoom: 12.0,
              ),
              mapController: MapController(),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point:
                          LatLng(45.5017, -73.5673), // Example marker location
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        // Updated from 'builder' to 'child'
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40.0,
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
