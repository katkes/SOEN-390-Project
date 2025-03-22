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

  late CalendarEventService calendarEventService;

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

    calendarEventService = CalendarEventService(
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
      final calendars = await calendarEventService.fetchCalendars();

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

  Future<void> fetchCalendarEvents({bool useCashe = true}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch all events using the service
      final allEventsByDay = await calendarEventService.fetchCalendarEvents(
          _selectedCalendarId ?? 'primary',
          useCache: useCashe);

      // If a calendar is selected, filter events for that calendar
      print("Fetched all events: $allEventsByDay");
      if (_selectedCalendarId != null) {
        final filteredEventsByDay = <DateTime, List<gcal.Event>>{};

        allEventsByDay.forEach((date, events) {
          for (var event in events) {
            print("Event ID: ${event.id}");
            print("Event Organizer Email: ${event.organizer?.email}");
            print("Event Creator Email: ${event.creator?.email}");
          }
          final filteredEvents = events.where((event) {
            // Filter events based on the selected calendar ID
            return event.organizer?.email == _selectedCalendarId ||
                event.creator?.email == _selectedCalendarId ||
                event.id?.contains(_selectedCalendarId!) == true;
          }).toList();

          if (filteredEvents.isNotEmpty) {
            filteredEventsByDay[date] = filteredEvents;
          }
        });

        setState(() {
          _eventsByDay = filteredEventsByDay;
          print(_eventsByDay);
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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await fetchCalendarEvents(useCashe: false);
                      print(_selectedCalendarId);
                      setState(() {
                        _isLoading = false;
                      });
                    } catch (e) {
                      setState(() {
                        _error = "Failed to refresh events: $e";
                        _isLoading = false;
                      });
                    }
                  },
                  tooltip: "Refresh Calendars",
                ),
                Expanded(
                  child: CalendarDropdown(
                    calendars: _calendars,
                    selectedCalendarId: _selectedCalendarId,
                    onCalendarSelected: (calendarId) {
                      setState(() {
                        _selectedCalendarId = calendarId;
                      });
                      fetchCalendarEvents();
                    },
                  ),
                ),
              ],
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
            child: EventListWidget(
              events: _getEventsForDay(_selectedDay!),
              calendarEventService: calendarEventService,
              calendarId: _selectedCalendarId ?? 'primary',
              calendarService: CalendarService(AuthRepository(
                authService: widget.authService,
                httpService: widget.authService.httpService,
                secureStorage: widget.authService.secureStorage,
              )),
              onEventChanged: () {
                fetchCalendarEvents(useCashe: false);
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => EventCreationPopup(
              onSave: (name, building, classroom, time, day,
                  recurringFrequency) async {
                List<DateTime> eventDates = [];

                switch (recurringFrequency) {
                  case "Daily":
                    for (int i = 0; i < 7; i++) {
                      eventDates.add(day.add(Duration(days: i)));
                    }
                    break;
                  case "Weekly":
                    for (int i = 0; i < 13; i++) {
                      eventDates.add(day.add(Duration(days: 7 * i)));
                    }
                    break;
                  case "Monthly":
                    for (int i = 0; i < 12; i++) {
                      int newMonth = day.month + i;
                      int yearOffset = (newMonth - 1) ~/ 12;
                      int adjustedMonth = ((newMonth - 1) % 12) + 1;

                      int daysInMonth =
                          DateTime(day.year + yearOffset, adjustedMonth + 1, 0)
                              .day;
                      int adjustedDay =
                          day.day > daysInMonth ? daysInMonth : day.day;

                      DateTime monthlyDate = DateTime(
                          day.year + yearOffset, adjustedMonth, adjustedDay);

                      eventDates.add(monthlyDate);
                    }
                    break;
                  default:
                    eventDates.add(day);
                }

                // Create and save events
                for (final eventDate in eventDates) {
                  final event = gcal.Event()
                    ..summary = name
                    ..location = "$building, $classroom"
                    ..start = gcal.EventDateTime(
                        dateTime: DateTime(eventDate.year, eventDate.month,
                            eventDate.day, time.hour, time.minute))
                    ..end = gcal.EventDateTime(
                        dateTime: DateTime(eventDate.year, eventDate.month,
                            eventDate.day, time.hour + 1, time.minute));

                  try {
                    final calendarService = CalendarService(AuthRepository(
                      authService: widget.authService,
                      httpService: widget.authService.httpService,
                      secureStorage: widget.authService.secureStorage,
                    ));
                    await calendarService.createEvent(
                        _selectedCalendarId ?? 'primary', event);
                  } catch (e) {
                    print(
                        "Error creating event on ${eventDate.toString()}: $e");
                  }
                }

                await fetchCalendarEvents();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Event "$name" saved with ${recurringFrequency ?? "no"} recurrence'),
                  ));
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
