// marker_tap_handler.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/building_info_api.dart';
import 'package:popover/popover.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:soen_390/widgets/building_information_popup.dart';

/// Handles tap interactions with map markers representing buildings.
///
/// This class manages:
/// * Updating building information in the UI
/// * Moving the map to focus on tapped buildings
/// * Displaying building information popovers
///
/// Example usage:
/// ```dart
/// final handler = MarkerTapHandler(
///   onBuildingInfoUpdated: (name, address) => updateUI(name, address),
///   mapController: mapController,
///   buildingPopUps: buildingPopUps,
/// );
/// ```
class MarkerTapHandler {
  final Function(String? name, String? address) onBuildingInfoUpdated;
  final MapController mapController;
  final BuildingPopUps buildingPopUps;
  bool _hasTapped = false;

  MarkerTapHandler({
    required this.onBuildingInfoUpdated,
    required this.mapController,
    required this.buildingPopUps,
  });
  void onMarkerTapped(
    double lat,
    double lon,
    String name,
    String address,
    Offset tapPosition,
    BuildContext context,
  ) {
    //this prevents multiple tapping
    if (_hasTapped) {
      return;
    }

    _hasTapped = true;

    onBuildingInfoUpdated(name, address);

    mapController.move(LatLng(lat, lon), 17.0);

    final offset = tapPosition.dy;

    buildingPopUps
        .fetchBuildingInformation(lat, lon, name)
        .then((buildingInfo) {
      String? photoUrl = buildingInfo["photo"];
      print("Fetched photo URL: $photoUrl");

      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          showPopover(
            context: context,
            bodyBuilder: (context) => BuildingInformationPopup(
              buildingName: name,
              buildingAddress: address,
              photoUrl: photoUrl,
            ),
            onPop: () {
              _hasTapped = false;
              print('Popover closed');
            },
            direction: PopoverDirection.top,
            width: 220,
            height: 180,
            arrowHeight: 15,
            arrowWidth: 20,
            backgroundColor: Colors.white,
            barrierColor: Colors.transparent,
            radius: 8,
            arrowDyOffset: offset - 180,
          );
        }
      });
    }).catchError((error) {
      print("Error fetching building photo: $error");
    });
  }
}
