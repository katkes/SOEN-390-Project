import 'package:flutter/material.dart';
import 'package:soen_390/widgets/shuttle_schedule_dispaly.dart';
import 'package:soen_390/services/shuttle_service.dart';
import 'package:soen_390/styles/theme.dart';

class ShuttleScheduleScreen extends StatelessWidget {
  const ShuttleScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = ShuttleService().getFridaySchedule();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shuttle Schedule"),
        backgroundColor: appTheme.colorScheme.primary,
        foregroundColor: appTheme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ShuttleScheduleDisplay(fridaySchedule: schedule),
        ),
      ),
    );
  }
}
