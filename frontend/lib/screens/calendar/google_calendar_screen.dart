import 'package:flutter/material.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/repositories/auth_repository.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:soen_390/styles/theme.dart';

/// A screen that displays the user's Google Calendar events.
/// Show upcoming classes and events in a structured format (list, calendar, or timeline view).
/// Show upcoming classes and events in a structured format (list, calendar, or timeline view).
/// Allow users to switch between their different calendars and save last selection.
/// Allow users to tap on an event for more details.
///
/// This screen uses the [CalendarService] to fetch the user's calendar events.
/// The screen displays the events in a [TableCalendar] widget and a list of events for the selected day.
/// The screen also displays a loading indicator while fetching events and an error message if an error occurs.
///
/// The screen requires an [AuthService] to fetch the user's calendar events.
/// The [AuthService] is passed to the screen as a parameter.
///
/// The screen uses the [AuthRepository] to manage authentication and fetch the user's calendar events.
/// The [AuthRepository] is initialized with the [AuthService] and required services.
///

class CalendarScreen extends StatefulWidget {
  final AuthService authService;

  const CalendarScreen({super.key, required this.authService});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isLoading = true;
  String? _error;
  late CalendarService _calendarService;
  late AuthRepository _authRepository;

  // Calendar controller
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map to store events by date
  Map<DateTime, List<gcal.Event>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();

    // Get the services from the authService that was passed to the widget
    final httpService = widget.authService.httpService;
    final secureStorage = widget.authService.secureStorage;

    // Initialize AuthRepository with the required services
    _authRepository = AuthRepository(
      authService: widget.authService,
      httpService: httpService,
      secureStorage: secureStorage,
    );

    // Initialize CalendarService with AuthRepository
    _calendarService = CalendarService(_authRepository);

    _selectedDay = _focusedDay;

    // Fetch the user's calendar events once initialized
    fetchCalendarEvents();
  }

  Future<void> fetchCalendarEvents() async {
    try {
      // Check if access token exists as a simple authentication check
      final accessToken =
          await widget.authService.secureStorage.getToken('access_token');

      if (accessToken == null) {
        setState(() {
          _error = "User is not authenticated.";
          _isLoading = false;
        });
        return;
      }

      // Fetch events using the calendar service
      final events = await _calendarService.fetchEvents();

      // Group events by date
      final eventsByDay = <DateTime, List<gcal.Event>>{};

      for (final event in events) {
        final startTime = event.start?.dateTime ??
            (event.start?.date != null
                ? DateTime.parse(event.start!.date! as String)
                : null);

        if (startTime != null) {
          final dateOnly =
              DateTime(startTime.year, startTime.month, startTime.day);

          if (eventsByDay[dateOnly] == null) {
            eventsByDay[dateOnly] = [];
          }
          eventsByDay[dateOnly]!.add(event);
        }
      }

      setState(() {
        _eventsByDay = eventsByDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  // Function to get events for a specific day
  List<gcal.Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Calendar"),
          foregroundColor: appTheme.colorScheme.onPrimary,
          backgroundColor: appTheme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Calendar"),
          foregroundColor: appTheme.colorScheme.onPrimary,
          backgroundColor: appTheme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Calendar"),
        foregroundColor: appTheme.colorScheme.onPrimary,
        backgroundColor: appTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
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
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null ||
                    _getEventsForDay(_selectedDay!).isEmpty
                ? const Center(child: Text("No events for selected day"))
                : ListView.builder(
                    itemCount: _getEventsForDay(_selectedDay!).length,
                    itemBuilder: (context, index) {
                      final event = _getEventsForDay(_selectedDay!)[index];

                      String timeString = '';
                      if (event.start?.dateTime != null) {
                        timeString =
                            DateFormat('h:mm a').format(event.start!.dateTime!);
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(event.summary ?? 'No Title'),
                          subtitle:
                              timeString.isNotEmpty ? Text(timeString) : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
