import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart' as location_service;
import 'package:soen_390/utils/campus_locator.dart';

const String kCampusSGW = 'SGW';
const String kCampusLoyola = 'Loyola';

class CampusSwitch extends StatefulWidget {
  final Function(String) onSelectionChanged;
  final Function(LatLng) onLocationChanged;
  final String selectedCampus;
  final CampusLocator? campusLocator;

  const CampusSwitch({
    super.key,
    required this.onSelectionChanged,
    required this.onLocationChanged,
    required this.selectedCampus,
    this.campusLocator,
  }) : assert(
          selectedCampus == kCampusSGW || selectedCampus == kCampusLoyola,
          'selectedCampus must be either "$kCampusSGW" or "$kCampusLoyola"',
        );

  @override
  State<CampusSwitch> createState() => CampusSwitchState();
}

class CampusSwitchState extends State<CampusSwitch> {
  late String selectedBuilding;
  final Map<String, LatLng> _campusLocations = {
    kCampusSGW: const LatLng(45.497856, -73.579588),
    kCampusLoyola: const LatLng(45.4581, -73.6391),
  };

  final Map<String, Widget> _campusOptions = {
    kCampusSGW: const Text(kCampusSGW,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
    kCampusLoyola: const Text(kCampusLoyola,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
  };

  @override
  void initState() {
    super.initState();
    selectedBuilding = widget.selectedCampus;
    _initClosestCampus();
  }

  @override
  void didUpdateWidget(CampusSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCampus != oldWidget.selectedCampus) {
      setState(() {
        selectedBuilding = widget.selectedCampus;
      });
    }
  }

  // Initializes the closest campus based on the user's current location.
  Future<void> _initClosestCampus() async {
    final locator = widget.campusLocator ??
        CampusLocator(
            locationService: location_service.LocationService.instance);

    final newCampus = await locator.findClosestCampus();

    if (mounted) {
      setState(() => selectedBuilding = newCampus);
      widget.onSelectionChanged(newCampus);
      widget.onLocationChanged(locator.getCoordinates(newCampus));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CupertinoSegmentedControl<String>(
          padding: EdgeInsets.zero,
          groupValue: selectedBuilding,
          children: _campusOptions,
          onValueChanged: (String newValue) {
            setState(() {
              selectedBuilding = newValue;
            });
            widget.onSelectionChanged(newValue);
            widget.onLocationChanged(_campusLocations[newValue]!);
          },
          borderColor: Colors.transparent,
          selectedColor: Colors.white,
          unselectedColor: Colors.transparent,
          pressedColor: Colors.white.withValues(
            red: 255,
            green: 255,
            blue: 255,
            alpha: 0.7,
          ),
        ),
      ),
    );
  }
}
