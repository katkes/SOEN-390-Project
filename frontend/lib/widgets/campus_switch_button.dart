import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart' as location_service;
import 'package:soen_390/utils/campus_locator.dart';

/// Symbolic constants for campus keys
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
  late String selectedCampus;

  // Private internal maps
  final Map<String, LatLng> _campusLocations = {
    kCampusSGW: const LatLng(45.497856, -73.579588),
    kCampusLoyola: const LatLng(45.4581, -73.6391),
  };

  final Map<String, Widget> _campusOptions = {
    kCampusSGW: const Text(kCampusSGW,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF912338))),
    kCampusLoyola: const Text(kCampusLoyola,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF912338))),
  };

  Map<String, LatLng> get campusLocations => Map.unmodifiable(_campusLocations);
  Map<String, Widget> get campusOptions => Map.unmodifiable(_campusOptions);

  @override
  void initState() {
    super.initState();
    selectedCampus = widget.selectedCampus;
    _initClosestCampus();
  }

  @override
  void didUpdateWidget(CampusSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCampus != oldWidget.selectedCampus) {
      setState(() {
        selectedCampus = widget.selectedCampus;
      });
    }
  }

  /// Initializes closest campus based on user's location.
  Future<void> _initClosestCampus() async {
    final locator = widget.campusLocator ??
        CampusLocator(
          locationService: location_service.LocationService.instance,
        );

    final newCampus = await locator.findClosestCampus();

    if (mounted) {
      setState(() => selectedCampus = newCampus);
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
          // color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CupertinoSegmentedControl<String>(
          padding: EdgeInsets.zero,
          groupValue: selectedCampus,
          children: campusOptions,
          onValueChanged: (String newValue) {
            setState(() {
              selectedCampus = newValue;
            });
            widget.onSelectionChanged(newValue);
            widget.onLocationChanged(campusLocations[newValue]!);
          },
          borderColor: Colors.grey,
          selectedColor: const Color(0xFFA9A9A9),
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
