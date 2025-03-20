import 'package:flutter/material.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/repositories/auth_repository.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soen_390/repositories/calendar_repository.dart';
import 'package:soen_390/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_event_service.dart';
import 'table_calendar_widget.dart';
import 'event_list_widget.dart';
import 'calendar_app_bar.dart';
import 'calendar_dropdown.dart';
import 'event_creation_widget.dart';
import 'package:intl/intl.dart';


/// A screen that displays the user's Google Calendar events.
/// Show upcoming classes and events in a structured format (list, calendar, or timeline view).
/// Show upcoming classes and events in a structured format (list, calendar, or timeline view).
/// Allow users to switch between their different calendars and save last selection.
/// Allow users to tap on an event for more details.
///
/// This screen uses the [CalendarService] AND [CalendarRepository]to fetch the user's calendar events.
/// The screen displays the events in a [TableCalendar] widget and a list of events for the selected day.
/// The screen also displays a loading indicator while fetching events and an error message if an error occurs.
///
/// The screen requires an [AuthService] to fetch the user's calendar events.
/// The [AuthService] is passed to the screen as a parameter.
///
/// The screen uses the [AuthRepository] to manage authentication and fetch the user's calendar events.
/// The [AuthRepository] is initialized with the [AuthService] and required services.
///

class CalendarScreen extends ConsumerStatefulWidget {
  final AuthService authService;

  const CalendarScreen({super.key, required this.authService});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _isLoading = true;
  String? _error;
  String? _selectedCalendarId;

  List<gcal.CalendarListEntry> _calendars = []; // List of user's calendars

  late CalendarEventService _calendarEventService;

  // Calendar controller
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map to store events by date
  Map<DateTime, List<gcal.Event>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _initialize();
  }

  Future<void> _initialize() async {
    final httpService = widget.authService.httpService;
    final secureStorage = widget.authService.secureStorage;

    // Initialize AuthRepository with the required services
    final authRepository = AuthRepository(
      authService: widget.authService,
      httpService: httpService,
      secureStorage: secureStorage,
    );

    // Initialize CalendarService with AuthRepository
    final calendarService = CalendarService(authRepository);

    // Initialize CalendarApi using the http client from httpService
    final calendarApi = gcal.CalendarApi(httpService.client);

    _calendarEventService = CalendarEventService(
        calendarRepository: CalendarRepository(calendarService,
            CacheService(await SharedPreferences.getInstance(), calendarApi)));

    await fetchCalendars();
  }

  Future<void> fetchCalendars() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch calendars using CalendarEventService
      final calendars = await _calendarEventService.fetchCalendars();

      setState(() {
        _calendars = calendars;
        // Set default selected calendar to the first one if not already set
        _selectedCalendarId ??=
            calendars.isNotEmpty ? calendars.first.id : null;
        _isLoading = false;
      });

      // Fetch events for the selected calendar
      await fetchCalendarEvents();
    } catch (e) {
      setState(() {
        _error = "Failed to load calendars: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCalendarEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch all events using the service
      final allEventsByDay = await _calendarEventService.fetchCalendarEvents();

      // If a calendar is selected, filter events for that calendar
      if (_selectedCalendarId != null) {
        // Filter events by the selected calendar ID
        final filteredEventsByDay = <DateTime, List<gcal.Event>>{};

        allEventsByDay.forEach((date, events) {
          final filteredEvents = events.where((event) {
            // Check if the event belongs to the selected calendar
            return event.organizer?.email == _selectedCalendarId ||
                event.id?.contains(_selectedCalendarId!) == true;
          }).toList();

          if (filteredEvents.isNotEmpty) {
            filteredEventsByDay[date] = filteredEvents;
          }
        });

        setState(() {
          _eventsByDay = filteredEventsByDay;
          _isLoading = false;
        });
      } else {
        // If no calendar is selected, show all events
        setState(() {
          _eventsByDay = allEventsByDay;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load events: $e";
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
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;
    void onItemTapped(int index) {
      ref.read(navigationProvider.notifier).setSelectedIndex(index);

      if (index != 2) {
        Navigator.pop(context);
      }
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Calendar"),
          foregroundColor: appTheme.colorScheme.onPrimary,
          backgroundColor: appTheme.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar:
            NavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: const CustomAppBar(),
        body: Center(child: Text(_error!)),
        bottomNavigationBar:
            NavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CalendarDropdown(
              calendars: _calendars,
              selectedCalendarId: _selectedCalendarId,
              onCalendarSelected: (calendarId) {
                setState(() {
                  _selectedCalendarId = calendarId;
                });
                fetchCalendarEvents(); // Fetch events for the selected calendar
              },
            ),
          ),
          TableCalendarWidget(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            calendarFormat: _calendarFormat,
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
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: EventListWidget(events: _getEventsForDay(_selectedDay!)),
          ),
        ],
      ),
   floatingActionButton: FloatingActionButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => EventCreationPopup(
        onSave: (name, building, classroom, time, day) async {
          final event = gcal.Event()
            ..summary = name
            ..location = "$building, $classroom"
            ..start = gcal.EventDateTime(dateTime: DateTime(
              day.year, day.month, day.day, time.hour, time.minute))
            ..end = gcal.EventDateTime(dateTime: DateTime(
              day.year, day.month, day.day, time.hour + 1, time.minute));

          try {
            final calendarService = CalendarService(AuthRepository(
              authService: widget.authService,
              httpService: widget.authService.httpService,
              secureStorage: widget.authService.secureStorage,
            ));
await calendarService.createEvent(
                _selectedCalendarId ?? 'primary', event);

            // Reload events after successfully creating the event
            await fetchCalendarEvents();
           
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) { 
                final BuildContext currentContext = context;
                if (currentContext.mounted) {
                  final snackBar = SnackBar(
                    content: Text('Event "$name" saved on ${DateFormat.yMd().format(day)} at ${time.format(currentContext)}'),
                  );
                  ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
                }
              }
            });
          } catch (e) {
         
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) { 
                final BuildContext currentContext = context;
                if (currentContext.mounted) {
                  final snackBar = SnackBar(
                    content: Text('Failed to save event: $e'),
                  );
                  ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
                }
              }
            });
          }
        },
      ),
    );
  },
  backgroundColor: const Color(0xFF004085),
  child: const Icon(Icons.add),
  mini: true,
),


      bottomNavigationBar:
          NavBar(selectedIndex: selectedIndex, onItemTapped: onItemTapped),
    );
  }
}
