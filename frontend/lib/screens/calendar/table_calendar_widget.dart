import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:soen_390/styles/theme.dart';

/// File that contains the TableCalendarWidget class
/// This class is a widget that displays a table calendar
/// It uses the table_calendar package to display a calendar
/// The widget is used in the CalendarScreen to display the calendar

class TableCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final List<gcal.Event> Function(DateTime) eventLoader;

  const TableCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: calendarFormat,
      eventLoader: eventLoader,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          color: appTheme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: appTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: Color.fromARGB(90, 183, 39, 39),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
