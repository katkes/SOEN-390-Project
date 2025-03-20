import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;

/// This file contains the CalendarDropdown class
/// This class is a widget that displays a dropdown menu
/// It is used in the CalendarScreen to display a dropdown menu
/// The dropdown menu is used to select a calendar

class CalendarDropdown extends StatelessWidget {
  final List<gcal.CalendarListEntry> calendars;
  final String? selectedCalendarId;
  final Function(String? calendarId) onCalendarSelected;

  const CalendarDropdown({
    super.key,
    required this.calendars,
    required this.selectedCalendarId,
    required this.onCalendarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<String>(
          value: selectedCalendarId,
          onChanged: (String? newCalendarId) {
            onCalendarSelected(newCalendarId);
          },
          items: calendars.map((calendar) {
            return DropdownMenuItem<String>(
              value: calendar.id,
              child: Text(calendar.summary ?? 'Unknown Calendar'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
