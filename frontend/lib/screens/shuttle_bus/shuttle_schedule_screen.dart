import 'package:flutter/material.dart';
import 'package:soen_390/widgets/shuttle_schedule_display.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';

// This screen displays the shuttle schedule for the app.
class ShuttleScheduleScreen extends StatelessWidget {
  const ShuttleScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the shuttle schedule for Friday.
    final fridaySchedule = ShuttleService().getFridaySchedule();
    // Fetch the shuttle schedule for Monday to Thursday.
    final mondayThursdaySchedule = ShuttleService().getMondayThursdaySchedule();

    return Scaffold(
      // AppBar with a title and theme-based colors.
      appBar: AppBar(
        title: const Text("Shuttle Schedule"),
        backgroundColor: appTheme.colorScheme.primary,
        foregroundColor: appTheme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Prevents overscrolling behavior.
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(4.0),
          // Displays the shuttle schedule using a custom widget.
          child: ShuttleScheduleDisplay(
            fridaySchedule: fridaySchedule,
            mondayThursdaySchedule: mondayThursdaySchedule,
          ),
        ),
      ),
    );
  }
}
