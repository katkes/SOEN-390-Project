import 'package:flutter/material.dart';

class BuildingSwitch extends StatefulWidget {
  final Function(String)
      onSelectionChanged; // callback function to notify switch of building
  final String initialSelection; // default value

  const BuildingSwitch({
    super.key,
    required this.onSelectionChanged,
    this.initialSelection = 'SGW', // optional parameter
  });

  @override
  State<BuildingSwitch> createState() => _BuildingSwitchState();
}

class _BuildingSwitchState extends State<BuildingSwitch> {
  late String selectedBuilding;

  @override
  void initState() {
    super.initState();
    selectedBuilding = widget.initialSelection;
  }

  // UI of widget
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment(value: 'SGW', label: Text('SGW')),
          ButtonSegment(value: 'Loyola', label: Text('Loyola'))
        ],
        selected: {
          selectedBuilding
        },
        // Callback triggered
        onSelectionChanged: (newSelection) {
          // Forcing the UI to rebuild
          setState(() {
            selectedBuilding = newSelection.first;
          });
        },
        style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              return states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.grey.shade300;
            }),
            side: WidgetStateProperty.resolveWith((_) => BorderSide.none),
            shape: WidgetStateProperty.resolveWith((_) =>
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)))));
  }
}
