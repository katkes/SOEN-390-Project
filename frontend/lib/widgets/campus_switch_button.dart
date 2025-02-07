import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    selectedBuilding = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Centering the widget
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          width: 250, // Made it skinnier
          child: SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment(value: 'SGW', label: Text('SGW')),
              ButtonSegment(value: 'Loyola', label: Text('Loyola')),
            ],
            selected: {selectedBuilding},
            onSelectionChanged: (newSelection) {
              setState(() {
                selectedBuilding = newSelection.first;
              });
            },
            style: ButtonStyle(
              textStyle: WidgetStateProperty.resolveWith(
                (Set<WidgetState> states) {
                  return states.contains(WidgetState.selected)
                      ? const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )
                      : const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        );
                },
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (Set<WidgetState> states) {
                  return states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.grey.shade300;
                },
              ),
              side: WidgetStateProperty.resolveWith((_) => BorderSide.none),
              shape: WidgetStateProperty.resolveWith(
                (_) => RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
