// LocationTransportSelector is responsible for handling user input related to
// selecting start and destination locations, adding stops, choosing transport modes,
// and setting departure options (Leave Now, Depart At, Arrive By).
// The confirmed waypoints and transport mode are sent to the routing system for processing.

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/suggestions.dart';

class LocationTransportSelector extends StatefulWidget {
  final Function(List<String>, String) onConfirmRoute;
  final Function(String)? onTransportModeChange;
  final Function()? onLocationChanged;

  const LocationTransportSelector(
      {super.key,
      this.onLocationChanged,
      required this.onConfirmRoute,
      this.onTransportModeChange});

  @override
  LocationTransportSelectorState createState() =>
      LocationTransportSelectorState();
}

class LocationTransportSelectorState extends State<LocationTransportSelector> {
  List<String> itinerary = [];
  String selectedMode = "Train or Bus";
  String selectedTimeOption = "Leave Now"; // Default time selection
  String selectedLocation = ''; //variable to store selected location address
  String startLocation = ''; // variable to store start location address
  String destinationLocation =
      ''; // variable to store destination location address

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
          //_buildReorderableItinerary(), temporarily removed
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
        _buildLocationField("Start Location", true),
        const SizedBox(height: 10),
        _buildLocationField("Destination", false),
        const SizedBox(height: 10),

        // Add Stop & "Leave Now" Dropdown in Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                if (itinerary.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Select both start and destination before adding!")),
                  );
                } else {
                  setState(() {
                    itinerary.add("New Stop ${itinerary.length + 1}");
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff912338),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xff912338)),
                ),
              ),
              child: const Text("Add Stop to Itinerary"),
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
                  value: selectedTimeOption, // Default value
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
        ),
      ],
    );
  }

  // TODO: Issue-128 - Reuse logic for UI to insert multiple tasks
  // Temporary removable until multiple iternary is implemented

  // Widget _buildReorderableItinerary() {
  //   return ReorderableListView(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     onReorder: (oldIndex, newIndex) {
  //       setState(() {
  //         if (newIndex > oldIndex) newIndex -= 1;
  //         final item = itinerary.removeAt(oldIndex);
  //         itinerary.insert(newIndex, item);
  //       });
  //     },
  //     children: [
  //       for (int index = 0; index < itinerary.length; index++)
  //         ListTile(
  //           key: ValueKey(itinerary[index]),
  //           title: Text(itinerary[index]),
  //           leading: const Icon(Icons.drag_handle),
  //           trailing: IconButton(
  //             icon: const Icon(Icons.delete, color: Colors.red),
  //             onPressed: () => _removeStop(index),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  void _confirmRoute() {
    if (itinerary.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must have at least a start and destination.")),
      );
      return;
    }

    List<String> selectedWaypoints = List.from(itinerary);
    print("Waypoints sent to routing system: $selectedWaypoints");

    widget.onConfirmRoute(selectedWaypoints, selectedMode);
  }

  Widget _buildLocationField(String placeholder, bool isStart) {
    String locationText = isStart ? startLocation : destinationLocation;
    locationText = locationText.isEmpty
        ? placeholder
        : locationText
            .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
            .split(' ') // Split by spaces
            .take(2) // Get only the first two words
            .join(' '); // Join them back to a string

    return GestureDetector(
      onTap: () {
        _showLocationSuggestions(isStart);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(locationText,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            if (locationText != placeholder)
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (isStart) {
                      startLocation = '';
                      _removeStop(0);
                    } else {
                      destinationLocation = '';
                      _removeStop(1);
                    }
                  });
                },
              ),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
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
    if (itinerary.isEmpty) {
      startLocation = selectedLocation;
      itinerary.add(selectedLocation);
    }
  }

  void _setDestinationLocation(String selectedLocation) {
    if (itinerary.length < 2) {
      destinationLocation = selectedLocation;
      itinerary.add(selectedLocation);
    }
  }

  void _removeStop(int index) {
    setState(() {
      itinerary.removeAt(index);
      if (widget.onLocationChanged != null) {
        widget.onLocationChanged!();
      }
    });
    if (widget.onTransportModeChange != null &&
        (index == 0 || itinerary.length < 2)) {
      // Let the parent know to clear cached routes
      widget.onTransportModeChange!("clear_cache");
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
        else if (itinerary.length >= 2) {
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
