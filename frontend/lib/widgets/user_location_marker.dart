import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class CurrentLocationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CurrentLocationLayer(
      positionStream: const LocationMarkerDataStreamFactory().fromGeolocatorPositionStream(),
      style: const LocationMarkerStyle(
        marker: DefaultLocationMarker(
          child: Icon(
            Icons.navigation,
            color: Colors.white,
          ),
        ),
        markerSize: Size(40, 40),
        markerDirection: MarkerDirection.heading,
      ),
    );
  }
}