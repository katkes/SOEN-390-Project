import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CampusSwitch extends StatefulWidget {
  final Function(String) onSelectionChanged;
  final String initialSelection;

  const CampusSwitch({
    super.key,
    required this.onSelectionChanged,
    this.initialSelection = 'SGW',
  });

  @override
  State<CampusSwitch> createState() => _CampusSwitchState();
}

class _CampusSwitchState extends State<CampusSwitch> {
  late String selectedBuilding;

  final Map<String, Widget> _campusOptions = {
    'SGW': Text('SGW',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
    'Loyola': Text('Loyola',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
  };

  @override
  void initState() {
    super.initState();
    selectedBuilding = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350, // Increased width to match Figma design
        padding: const EdgeInsets.all(4), // Padding to match the rounded look
        decoration: BoxDecoration(
          color:
              Colors.grey.shade300, // Background color of the unselected area
          borderRadius: BorderRadius.circular(12), // Smooth corner radius
        ),
        child: CupertinoSegmentedControl<String>(
          padding: EdgeInsets.zero, // No additional padding
          groupValue: selectedBuilding,
          children: _campusOptions,
          onValueChanged: (String newValue) {
            setState(() {
              selectedBuilding = newValue;
            });
            widget.onSelectionChanged(newValue);
          },
          borderColor: Colors.transparent, // Remove border
          selectedColor: Colors.white, // Active button color
          unselectedColor:
              Colors.transparent, // Unselected color blends into background
          pressedColor: Colors.white.withOpacity(0.7), // Subtle press effect
        ),
      ),
    );
  }
}
