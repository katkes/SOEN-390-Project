import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import "package:geolocator/geolocator.dart";
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import "package:soen_390/utils/location_service.dart";


class CurrentLocationWidget extends StatelessWidget {

  final LocationService locationService = LocationService.instance;


  @override
  Widget build(BuildContext context) {

    locationService.createLocationStream();
    var stream = locationService.getPositionStream();
    return CurrentLocationLayer(
       positionStream: const LocationMarkerDataStreamFactory().fromGeolocatorPositionStream(),

      // followOnLocationUpdate: FollowOnLocationUpdate.always,
      // turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
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