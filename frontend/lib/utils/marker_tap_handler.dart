// marker_tap_handler.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/services/building_info_api.dart';
import 'package:popover/popover.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:soen_390/widgets/building_information_popup.dart';

class MarkerTapHandler {
  final Function(String? name, String? address) onBuildingInfoUpdated;
  final MapController mapController;
  final BuildingPopUps buildingPopUps;

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
  onBuildingInfoUpdated(name, address);

  mapController.move(LatLng(lat, lon), 17.0);

  
  final offset = tapPosition.dy; 

  buildingPopUps.fetchBuildingInformation(lat, lon, name).then((buildingInfo) {
    String? photoUrl = buildingInfo["photo"];
    print("Fetched photo URL: $photoUrl");

    Future.delayed(const Duration(milliseconds: 300), () {
      showPopover(
        context: context,
        bodyBuilder: (context) => BuildingInformationPopup(
          buildingName: name,
          buildingAddress: address,
          photoUrl: photoUrl,
        ),
        onPop: () => print('Popover closed'),
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
    });
  }).catchError((error) {
    print("Error fetching building photo: $error");
  });
}

}
