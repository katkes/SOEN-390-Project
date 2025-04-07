// LocationTransportSelector is responsible for handling user input related to
// selecting start and destination locations, adding stops, choosing transport modes,
// and setting departure options (Leave Now, Depart At, Arrive By).
// The confirmed waypoints and transport mode are sent to the routing system for processing.

import 'package:flutter/material.dart';
import 'package:soen_390/screens/outdoor_poi/place_search_screen.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/location_updater.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/widgets/suggestions.dart';
import 'package:soen_390/widgets/location_field.dart';
import 'package:soen_390/utils/itinerary_manager.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/screens/shuttle_bus/shuttle_schedule_screen.dart';

class LocationTransportSelector extends StatefulWidget {
  final Function(List<String>, String) onConfirmRoute;
  final Function(String)? onTransportModeChange;
  final Function()? onLocationChanged;
  final String? initialDestination;

  final LocationService locationService;
  final GooglePOIService poiService;
  final PointOfInterestFactory poiFactory;
  final LocationUpdater locationUpdater;

  const LocationTransportSelector({
    super.key,
    required this.locationService,
    required this.poiService,
    required this.poiFactory,
    required this.locationUpdater,
    this.onLocationChanged,
    required this.onConfirmRoute,
    this.onTransportModeChange,
    this.initialDestination,
  });

  @override
  LocationTransportSelectorState createState() =>
      LocationTransportSelectorState();
}

class LocationTransportSelectorState extends State<LocationTransportSelector> {
  final List<Map<String, dynamic>> _transportOptions = [
    {"label": "Car", "icon": Icons.directions_car},
    {"label": "Bike", "icon": Icons.directions_bike},
    {"label": "Train or Bus", "icon": Icons.train},
    {"label": "Walk", "icon": Icons.directions_walk},
  ];
  static const String _defaultLocation = "Your Location";
  late ItineraryManager itineraryManager;
  String selectedMode = "Train or Bus";
  String selectedTimeOption = "Leave Now"; // Default time selection
  String selectedLocation = ''; //variable to store selected location address
  String startLocation =
      _defaultLocation; // variable to store start location address
  String defaultYourLocationString = _defaultLocation;
  String destinationLocation =
      ''; // variable to store destination location address

  static const int _startLocationIndex = 0;
  static const int _destinationIndex = 1;

  @override
  void initState() {
    super.initState();
    itineraryManager = ItineraryManager(itinerary: []);

    if (widget.initialDestination != null) {
      destinationLocation = widget.initialDestination!;
      itineraryManager.setDestination(destinationLocation);
    }

    startLocation = itineraryManager.getStart();
  }

  void _handleShuttleBusSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShuttleScheduleScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          _buildLocationInput(),
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          _buildTransportModeSelection(context),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _confirmRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: appTheme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Confirm Route"),
              ),
              ElevatedButton(
                onPressed: () {
                  _handleShuttleBusSelection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Shuttle Bus"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput() {
    return Column(
      children: [
        LocationField(
          text: startLocation,
          placeholder: defaultYourLocationString,
          onTap: () => _showLocationSuggestions(true),
          onDelete: () {
            setState(() {
              startLocation = '';
            });
            // ignore: unused_local_variable
            final currentLocation = widget.locationService.getCurrentLocation();
            setState(() {
              startLocation = _defaultLocation;
              itineraryManager.setStart(_defaultLocation);
            });
          },
          showDelete: startLocation != defaultYourLocationString,
        ),
        const SizedBox(height: 10),
        LocationField(
          text: destinationLocation,
          placeholder: "Destination",
          onTap: () => _showLocationSuggestions(false),
          onDelete: () {
            setState(() {
              destinationLocation = '';
              _removeStop(_destinationIndex);
            });
          },
          showDelete: destinationLocation.isNotEmpty,
        ),
        const SizedBox(height: 10),
        _buildNearbyAndTimeSelector(context), //
      ],
    );
  }

  void _confirmRoute() {
    if (!itineraryManager.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must have at least a start and destination.")),
      );
      return;
    }

    widget.onConfirmRoute(itineraryManager.getWaypoints(), selectedMode);
  }

  void _showLocationSuggestions(bool isStart) {
    showDialog(
      context: context,
      builder: (context) {
        return SuggestionsPopup(
          onSelect: (selectedLocation) {
            if (mounted) {
              setState(() {
                if (isStart) {
                  _setStartLocation(selectedLocation);
                } else {
                  _setDestinationLocation(selectedLocation);
                }
                widget.onLocationChanged?.call();
              });
            }
          },
        );
      },
    ).then((_) {});
  }

  void _setStartLocation(String selectedLocation) {
    startLocation = selectedLocation;
    itineraryManager.setStart(selectedLocation);
  }

  void _setDestinationLocation(String selectedLocation) {
    destinationLocation = selectedLocation;
    itineraryManager.setDestination(selectedLocation);
  }

  void _removeStop(int index) {
    setState(() {
      itineraryManager.removeAt(index);

      if (index == _startLocationIndex) {
        startLocation = defaultYourLocationString;
        itineraryManager.setStart(defaultYourLocationString);
      }

      widget.onLocationChanged?.call();
    });

    if (index == ItineraryManager.startIndex || !itineraryManager.isValid()) {
      widget.onTransportModeChange?.call("clear_cache");
    }
  }

  //public methods to facilitate testing
  void removeStopForTest(int index) {
    _removeStop(index);
  }

  void setStartLocation(String selectedLocation) {
    startLocation = selectedLocation;
    itineraryManager.setStart(selectedLocation);
  }

  void setDestinationLocation(String selectedLocation) {
    destinationLocation = selectedLocation;
    itineraryManager.setDestination(selectedLocation);
  }

  Widget _buildTransportModeSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _transportOptions.map((option) {
        return _buildTransportMode(
          context,
          option["label"],
          option["icon"],
          isSelected: selectedMode == option["label"],
        );
      }).toList(),
    );
  }

  Widget _buildNearbyAndTimeSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () async {
            final locationService = widget.locationService;
            final poiService = widget.poiService;
            final poiFactory = widget.poiFactory;
            final locationUpdater = widget.locationUpdater;

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceSearchScreen(
                  locationService: locationService,
                  poiService: poiService,
                  poiFactory: poiFactory,
                  onSetDestination: (name, lat, lng) {
                    setState(() {
                      destinationLocation = name;
                      itineraryManager.setDestination(name);
                    });
                    widget.onLocationChanged?.call();
                  },
                  locationUpdater: locationUpdater,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black),
            ),
          ),
          child: const Text("What's Nearby?"),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black26),
            //color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedTimeOption,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTimeOption = newValue!;
                });
              },
              items: <String>["Leave Now", "Depart At", "Arrive By"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportMode(BuildContext context, String label, IconData icon,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = label;
        });

        if (widget.onTransportModeChange != null) {
          widget.onTransportModeChange!(label);
        } else if (itineraryManager.isValid()) {
          widget.onConfirmRoute(itineraryManager.getWaypoints(), selectedMode);
        }
      },
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.black54,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
