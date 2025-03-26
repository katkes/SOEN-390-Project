// LocationTransportSelector is responsible for handling user input related to
// selecting start and destination locations, adding stops, choosing transport modes,
// and setting departure options (Leave Now, Depart At, Arrive By).
// The confirmed waypoints and transport mode are sent to the routing system for processing.

import 'package:flutter/material.dart';
import 'package:soen_390/screens/outdoor_poi/place_search_screen.dart';
import 'package:soen_390/services/google_poi_service.dart';
import 'package:soen_390/services/poi_factory.dart';
import 'package:soen_390/utils/location_service.dart';
import 'package:soen_390/widgets/suggestions.dart';
import 'package:soen_390/widgets/location_field.dart';

class LocationTransportSelector extends StatefulWidget {
  final Function(List<String>, String) onConfirmRoute;
  final Function(String)? onTransportModeChange;
  final Function()? onLocationChanged;
  final String? initialDestination;

  final LocationService locationService;
  final GooglePOIService poiService;
  final PointOfInterestFactory poiFactory;

  const LocationTransportSelector({
    super.key,
    required this.locationService,
    required this.poiService,
    required this.poiFactory,
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
  List<String> itinerary = [];
  String selectedMode = "Train or Bus";
  String selectedTimeOption = "Leave Now"; // Default time selection
  String selectedLocation = ''; //variable to store selected location address
  String startLocation =
      'Your Location'; // variable to store start location address
  String defaultYourLocationString = 'Your Location';
  String destinationLocation =
      ''; // variable to store destination location address

  static const int _destinationIndex = 1;
  static const int _minItineraryLength = 2;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null) {
      destinationLocation = widget.initialDestination!;

      if (itinerary.length > 1) {
        itinerary[1] = widget.initialDestination!;
      } else if (itinerary.length == 1) {
        itinerary.add(widget.initialDestination!);
      } else {
        itinerary.add(widget.initialDestination!);
      }
    }
    if (itinerary.isEmpty) {
      itinerary.add(defaultYourLocationString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          _buildLocationInput(),
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          _buildTransportModeSelection(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _confirmRoute,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff912338),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Confirm Route"),
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
              _removeStop(0);
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
              _removeStop(1);
            });
          },
          showDelete: destinationLocation.isNotEmpty,
        ),
        const SizedBox(height: 10),
        _buildNearbyAndTimeSelector(), //
      ],
    );
  }


  void _confirmRoute() {
    if (itinerary.length < _minItineraryLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must have at least a start and destination.")),
      );
      return;
    }

    List<String> selectedWaypoints = List.from(itinerary);

    widget.onConfirmRoute(selectedWaypoints, selectedMode);
  }

  void _showLocationSuggestions(bool isStart) {
    showDialog(
      context: context,
      builder: (context) {
        return SuggestionsPopup(
          onSelect: (selectedLocation) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _handleLocationSelection(selectedLocation, isStart);
              }
            });
          },
        );
      },
    );
  }

  void _handleLocationSelection(String selectedLocation, bool isStart) {
    setState(() {
      if (isStart) {
        _setStartLocation(selectedLocation);
      } else {
        _setDestinationLocation(selectedLocation);
      }
      widget.onLocationChanged?.call();
    });
  }

  void _setStartLocation(String selectedLocation) {
    startLocation = selectedLocation;

    if (itinerary.isEmpty) {
      itinerary.add(selectedLocation);
    } else {
      itinerary.insert(0, selectedLocation);
      itinerary.removeAt(1);
    }
  }

  void _setDestinationLocation(String selectedLocation) {
    if (itinerary.length < _minItineraryLength) {
      destinationLocation = selectedLocation;
      itinerary.add(selectedLocation);
    }
  }

  static const int _startLocationIndex = 0;
  static const int _minimumWaypoints = 2;

  void _removeStop(int index) {
    setState(() {
      itinerary.removeAt(index);
      widget.onLocationChanged?.call();
    });

    if (index == _startLocationIndex || itinerary.length < _minimumWaypoints) {
      widget.onTransportModeChange?.call("clear_cache");
    }
  }

  //public methods to facilitate testing
  void removeStopForTest(int index) {
    _removeStop(index);
  }

  void setStartLocation(String selectedLocation) {
    startLocation = selectedLocation;

    if (itinerary.isEmpty) {
      itinerary.add(selectedLocation);
    } else {
      itinerary.insert(0, selectedLocation);
    }
  }

  void setDestinationLocation(String selectedLocation) {
    destinationLocation = selectedLocation;
    if (itinerary.length < _minItineraryLength) {
      itinerary.add(selectedLocation);
    } else if (itinerary.length == _minItineraryLength) {
      itinerary[1] = selectedLocation;
    }
  }

  Widget _buildTransportModeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTransportMode("Car", Icons.directions_car),
        _buildTransportMode("Bike", Icons.directions_bike),
        _buildTransportMode("Train or Bus", Icons.train, isSelected: true),
        _buildTransportMode("Walk", Icons.directions_walk),
      ],
    );
  }
  Widget _buildNearbyAndTimeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () async {
            final locationService = widget.locationService;
            final poiService = widget.poiService;
            final poiFactory = widget.poiFactory;

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
                      if (itinerary.length < _minItineraryLength) {
                        itinerary.add(name);
                      } else {
                        itinerary[_destinationIndex] = name;
                      }
                    });
                    widget.onLocationChanged?.call();
                  },
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xff912338),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xff912338)),
            ),
          ),
          child: const Text("What's Nearby?"),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black26),
            color: Colors.white,
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


  Widget _buildTransportMode(String label, IconData icon,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = label;
        });

        if (widget.onTransportModeChange != null) {
          widget.onTransportModeChange!(label);
        }
        // Otherwise use the confirm route handler if we have waypoints
        else if (itinerary.length >= _minItineraryLength) {
          widget.onConfirmRoute(List.from(itinerary), selectedMode);
        }
      },
      child: Column(
        children: [
          Icon(icon,
              size: 28,
              color: selectedMode == label
                  ? const Color(0xFF912338)
                  : Colors.black54),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: selectedMode == label
                    ? const Color(0xFF912338)
                    : Colors.black54),
          ),
        ],
      ),
    );
  }
}
