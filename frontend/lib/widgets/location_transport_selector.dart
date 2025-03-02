// LocationTransportSelector is responsible for handling user input related to
// selecting start and destination locations, adding stops, choosing transport modes,
// and setting departure options (Leave Now, Depart At, Arrive By).
// Users can reorder their itinerary using drag-and-drop functionality and confirm their route.
// The confirmed waypoints and transport mode are sent to the routing system for processing.

import 'package:flutter/material.dart';
import 'suggestions.dart';

class LocationTransportSelector extends StatefulWidget {
  final Function(List<String>, String) onConfirmRoute;

  const LocationTransportSelector({super.key, required this.onConfirmRoute});

  @override
  LocationTransportSelectorState createState() =>
      LocationTransportSelectorState();
}

class LocationTransportSelectorState extends State<LocationTransportSelector> {
  List<String> itinerary = [];
  String selectedMode = "Train or Bus";
  String selectedTimeOption = "Leave Now"; // Default time selection
  bool isShuttleChecked = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
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
            _buildReorderableItinerary(),
            const SizedBox(height: 20),
            _buildTransportModeSelection(),
            const SizedBox(height: 10),
            _buildShuttleCheckbox(),
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

        // ✅ Add Stop & "Leave Now" Dropdown in Row
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildShuttleCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: isShuttleChecked,
          onChanged: (bool? newValue) {
            setState(() {
              isShuttleChecked = newValue ?? false;
              if (isShuttleChecked) {
                print("Shuttle service selected. Returning fake response.");
              }
            });
          },
        ),
        const Text("Shuttle", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildReorderableItinerary() {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = itinerary.removeAt(oldIndex);
          itinerary.insert(newIndex, item);
        });
      },
      children: [
        for (int index = 0; index < itinerary.length; index++)
          ListTile(
            key: ValueKey(itinerary[index]),
            title: Text(itinerary[index]),
            leading: const Icon(Icons.drag_handle),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeStop(index),
            ),
          ),
      ],
    );
  }

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Route successfully confirmed!")),
    );
  }

  Widget _buildLocationField(String placeholder, bool isStart) {
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
            Text(placeholder,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
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
                setState(() {
                  if (isStart && itinerary.isEmpty) {
                    itinerary.add(selectedLocation);
                  } else if (!isStart && itinerary.length < 2) {
                    itinerary.add(selectedLocation);
                  }
                });
              }
            });
          },
        );
      },
    );
  }

  void _removeStop(int index) {
    setState(() {
      itinerary.removeAt(index);
    });
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
