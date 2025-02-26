import 'package:flutter/material.dart';
import 'package:soen_390/widgets/suggestions.dart';

class LocationTransportSelector extends StatefulWidget {
  const LocationTransportSelector({super.key});

  @override
  LocationTransportSelectorState createState() =>
      LocationTransportSelectorState();
}

class LocationTransportSelectorState extends State<LocationTransportSelector> {
  String currentLocation = "Current Location";
  String destination = "Hall Building";
  String selectedMode = "Train or Bus";
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
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.radio_button_checked,
                      color: Color(0xFF912338), size: 20),
                  Container(
                      height: 40, width: 2, color: const Color(0xFF912338)),
                  const Icon(Icons.location_pin,
                      color: Color(0xFF912338), size: 20),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    buildLocationField(
                        "Current Location", currentLocation, true),
                    const SizedBox(height: 10),
                    buildLocationField("Destination", destination, false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTransportMode("Car", Icons.directions_car),
              _buildTransportMode("Bike", Icons.directions_bike),
              _buildTransportMode("Train or Bus", Icons.train,
                  isSelected: true),
              _buildTransportMode("Walk", Icons.directions_walk),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLocationField(String placeholder, String value, bool isCurrent) {
    return GestureDetector(
      onTap: () {
        showLocationSuggestions(isCurrent);
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
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void showLocationSuggestions(bool isCurrent) {
    showDialog(
      context: context,
      builder: (context) {
        return SuggestionsPopup(
          onSelect: (selectedLocation) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  if (isCurrent) {
                    currentLocation = selectedLocation;
                  } else {
                    destination = selectedLocation;
                  }
                });
              }
            });
          },
        );
      },
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
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
