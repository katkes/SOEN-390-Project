import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart' as location_service;

class CampusSwitch extends StatefulWidget {
  final Function(String) onSelectionChanged;
  final Function(LatLng) onLocationChanged;
  final String selectedCampus;

  const CampusSwitch({
    super.key,
    required this.onSelectionChanged,
    required this.onLocationChanged,
    required this.selectedCampus,
  }) : assert(
  selectedCampus == 'SGW' || selectedCampus == 'Loyola',
  'selectedCampus must be either "SGW" or "Loyola"',
  );

  @override
  State<CampusSwitch> createState() => CampusSwitchState();
}

class CampusSwitchState extends State<CampusSwitch> {
  late String selectedBuilding;
  final Map<String, LatLng> _campusLocations = {
    'SGW': const LatLng(45.497856, -73.579588),
    'Loyola': const LatLng(45.4581, -73.6391),
  };

  final Map<String, Widget> _campusOptions = {
    'SGW': const Text('SGW',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
    'Loyola': const Text('Loyola',
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
    // Get the singleton instance.
    final locationService = location_service.LocationService.instance;

    try {
      // Await startUp() so that exceptions are caught.
      await locationService.startUp();

      // Retrieve the current location and determine the closest campus.
      final newBuilding = (location_service.LocationService.getClosestCampus(
          await locationService.getCurrentLocation()) ==
          "LOY")
          ? "Loyola"
          : "SGW";

      if (mounted) {
        setState(() => selectedBuilding = newBuilding);
        widget.onSelectionChanged(selectedBuilding);
        widget.onLocationChanged(_campusLocations[selectedBuilding]!);
      }
    } catch (e) {
      // For error handling (ex. location services disabled).
      print('Error initializing closest campus: $e');

      // Determine if location services are enabled.
      if (!await locationService.determinePermissions()) {
        print('Location services are disabled.');
      }
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
