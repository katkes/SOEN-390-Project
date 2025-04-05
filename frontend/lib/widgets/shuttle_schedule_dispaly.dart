import 'package:flutter/material.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/shuttle_schedule_dispaly_widgets.dart'; 

class ShuttleScheduleDisplay extends StatefulWidget {
  final ShuttleSchedule fridaySchedule;
  final ShuttleSchedule mondayThursdaySchedule;

  const ShuttleScheduleDisplay({
    super.key,
    required this.fridaySchedule,
    required this.mondayThursdaySchedule,
  });

  @override
  State<ShuttleScheduleDisplay> createState() => _ShuttleScheduleDisplayState();
}

class _ShuttleScheduleDisplayState extends State<ShuttleScheduleDisplay> {
  bool _isFridaySchedule = true;

  ShuttleSchedule get _currentSchedule =>
      _isFridaySchedule ? widget.fridaySchedule : widget.mondayThursdaySchedule;

  String get _scheduleTitle => _isFridaySchedule
      ? "Shuttle Bus Schedule (Friday)"
      : "Shuttle Bus Schedule (Mon-Thurs)";

  String get _toggleButtonText => _isFridaySchedule
      ? 'Show Mon-Thurs Schedule'
      : 'Show Friday Schedule';

  void _toggleSchedule() {
    setState(() {
      _isFridaySchedule = !_isFridaySchedule;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: _toggleSchedule,
            child: Text(_toggleButtonText),
          ),
          const SizedBox(height: 20),
          Text(
            _scheduleTitle,
            style: appTheme.textTheme.titleLarge?.copyWith(
                color: appTheme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(height: 20),
          ScheduleList(
            title: "LOY Departures",
            times: _currentSchedule.loyDepartures,
          ),
          const SizedBox(height: 20),
          ScheduleList(
            title: "SGW Departures",
            times: _currentSchedule.sgwDepartures,
          ),
          const SizedBox(height: 20),
          StopLocations(schedule: _currentSchedule),
        ],
      ),
    );
  }
}