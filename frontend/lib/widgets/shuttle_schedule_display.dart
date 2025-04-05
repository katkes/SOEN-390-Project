import 'package:flutter/material.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/shuttle_schedule_display_widgets.dart'; 

// Main widget to display the shuttle schedule
class ShuttleScheduleDisplay extends StatefulWidget {
  final ShuttleSchedule fridaySchedule; // Schedule for Fridays
  final ShuttleSchedule mondayThursdaySchedule; // Schedule for Monday to Thursday

  const ShuttleScheduleDisplay({
    super.key,
    required this.fridaySchedule,
    required this.mondayThursdaySchedule,
  });

  @override
  State<ShuttleScheduleDisplay> createState() => _ShuttleScheduleDisplayState();
}

class _ShuttleScheduleDisplayState extends State<ShuttleScheduleDisplay> {
  bool _isFridaySchedule = true; // Tracks whether the Friday schedule is active

  // Returns the current schedule based on the selected day
  ShuttleSchedule get _currentSchedule =>
      _isFridaySchedule ? widget.fridaySchedule : widget.mondayThursdaySchedule;

  // Returns the title of the schedule based on the selected day
  String get _scheduleTitle => _isFridaySchedule
      ? "Shuttle Bus Schedule (Friday)"
      : "Shuttle Bus Schedule (Mon-Thurs)";

  // Returns the text for the toggle button
  String get _toggleButtonText => _isFridaySchedule
      ? 'Show Mon-Thurs Schedule'
      : 'Show Friday Schedule';

  // Toggles between Friday and Mon-Thurs schedules
  void _toggleSchedule() {
    setState(() {
      _isFridaySchedule = !_isFridaySchedule;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16), // Outer margin for the container
      padding: const EdgeInsets.all(16), // Inner padding for the container
      decoration: BoxDecoration(
        color: appTheme.colorScheme.onPrimary, // Background color
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)], // Shadow effect
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start
        children: [
          // Button to toggle between schedules
          ElevatedButton(
            onPressed: _toggleSchedule,
            child: Text(_toggleButtonText),
          ),
          const SizedBox(height: 20), // Spacing between elements
          // Title of the schedule
          Text(
            _scheduleTitle,
            style: appTheme.textTheme.titleLarge?.copyWith(
                color: appTheme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(height: 20),
          // List of LOY departures
          ScheduleList(
            title: "LOY Departures",
            times: _currentSchedule.loyDepartures,
          ),
          const SizedBox(height: 20),
          // List of SGW departures
          ScheduleList(
            title: "SGW Departures",
            times: _currentSchedule.sgwDepartures,
          ),
          const SizedBox(height: 20),
          // Stop locations for the current schedule
          StopLocations(schedule: _currentSchedule),
        ],
      ),
    );
  }
}