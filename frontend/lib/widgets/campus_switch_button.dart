import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:soen_390/utils/location_service.dart' as location_service;
import 'package:geolocator/geolocator.dart' as geolocator;

class CampusSwitch extends StatefulWidget {
  final Function(String) onSelectionChanged;
  final Function(LatLng) onLocationChanged;
  final String initialSelection;

  const CampusSwitch({
    super.key,
    required this.onSelectionChanged,
    required this.onLocationChanged,
    this.initialSelection = 'SGW',
  }) : assert(
          initialSelection == 'SGW' || initialSelection == 'Loyola',
          'initialSelection must be either "SGW" or "Loyola"',
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
    selectedBuilding = widget.initialSelection;
    _initClosestCampus();
  }

  // Initializes the closest campus based on the user's current location.
  Future<void> _initClosestCampus() async {
    // Get the singleton instance.
    final locationService = location_service.LocationService.instance;

    try {
      // Await startUp() so that exceptions are caught.
      await locationService.startUp();

      // Determine if location services are enabled.
      bool locationEnabled = await locationService.determinePermissions();
      if (!locationEnabled) {
        print('Location services are disabled.');
        return;
      }

      // Retrieve the current location.
      geolocator.Position currentPos =
          await locationService.getCurrentLocation();

      final newBuilding =
          (location_service.LocationService.getClosestCampus(currentPos) ==
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
