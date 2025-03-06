import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';


class CurrentLocationWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return CurrentLocationLayer(
       positionStream: const LocationMarkerDataStreamFactory().fromGeolocatorPositionStream(),


      style: const LocationMarkerStyle(
        marker: DefaultLocationMarker(
          child: Icon(
            //Icons.navigation,
            Icons.location_pin,
            color: Colors.white,
          ),
        ),
        markerSize: Size(40, 40),
        markerDirection: MarkerDirection.heading,
      ),
    );
  }
}