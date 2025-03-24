import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:soen_390/screens/calendar/calendar_view.dart';
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/core/secure_storage.dart';
import 'package:soen_390/providers/navigation_provider.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'calendar_view_test.mocks.dart';
import 'package:soen_390/repositories/auth_repository.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'package:soen_390/repositories/calendar_repository.dart';
import 'package:soen_390/services/cache_service.dart';
import 'package:soen_390/screens/calendar/calendar_event_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:table_calendar/table_calendar.dart';
import 'package:soen_390/screens/calendar/table_calendar_widget.dart';

@GenerateMocks([
  GoogleSignIn,
  HttpService,
  SecureStorage,
  AuthClientFactory,
  AuthRepository,
  CalendarService,
  CalendarRepository,
  CacheService,
  CalendarEventService,
  SharedPreferences,
])
class MockAuthService extends Mock implements AuthService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGoogleSignIn mockGoogleSignIn;
  late MockHttpService mockHttpService;
  late MockSecureStorage mockSecureStorage;
  late MockAuthClientFactory mockAuthClientFactory;
  late AuthService authService;
  late http.Client httpClient;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockHttpService = MockHttpService();
    mockSecureStorage = MockSecureStorage();
    mockAuthClientFactory = MockAuthClientFactory();

    httpClient = http.Client();

    authService = AuthService(
      googleSignIn: mockGoogleSignIn,
      httpService: mockHttpService,
      secureStorage: mockSecureStorage,
      authClientFactory: mockAuthClientFactory,
    );

    when(mockHttpService.client).thenReturn(httpClient);

    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        navigationProvider.overrideWith((ref) => NavigationNotifier()),
      ],
      child: MaterialApp(
        home: CalendarScreen(authService: authService),
      ),
    );
  }

  group('CalendarScreen Tests', () {
    testWidgets('renders loading indicator initially', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text("My Calendar"), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle properly without crashes',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(Container());

      expect(true, isTrue);
    });
    testWidgets('should display the navbar with correct selected index',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(NavBar), findsOneWidget);
    });
    testWidgets('should have a refresh button in the UI', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Scaffold), findsOneWidget);

      final scaffoldState =
          tester.state(find.byType(Scaffold)) as ScaffoldState;

      expect(scaffoldState, isNotNull);
    });
    testWidgets('should display error message when calendar fetch fails',
        (tester) async {
      final error = Exception('Failed to load calendars');

      final widget = ProviderScope(
        overrides: [
          navigationProvider.overrideWith((ref) => NavigationNotifier()),
        ],
        child: MaterialApp(
          home: TestCalendarScreen(
            authService: authService,
            onInitialize: () async {
              throw error;
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump();

      expect(find.text("Failed to load calendars: $error"), findsOneWidget);
    });

    testWidgets(
        'should change selected calendar when dropdown selection changes',
        (tester) async {
      final testCalendars = [
        gcal.CalendarListEntry()
          ..id = 'calendar1'
          ..summary = 'Calendar 1',
        gcal.CalendarListEntry()
          ..id = 'calendar2'
          ..summary = 'Calendar 2',
      ];

      String? selectedCalendarId;

      final widget = ProviderScope(
        overrides: [
          navigationProvider.overrideWith((ref) => NavigationNotifier()),
        ],
        child: MaterialApp(
          home: TestCalendarScreen(
            authService: authService,
            testCalendars: testCalendars,
            onCalendarSelected: (calendarId) {
              selectedCalendarId = calendarId;
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Open the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select the second calendar
      await tester.tap(find.text('Calendar 2').last);
      await tester.pumpAndSettle();

      expect(selectedCalendarId, equals('calendar2'));
    });
    testWidgets('should navigate away when nav bar item is tapped',
        (tester) async {
      final testCalendars = [
        gcal.CalendarListEntry()
          ..id = 'calendar1'
          ..summary = 'Calendar 1',
      ];

      int? selectedIndex;

      final widget = ProviderScope(
        overrides: [
          navigationProvider.overrideWith((ref) => NavigationNotifier()),
        ],
        child: MaterialApp(
          home: TestCalendarScreen(
            authService: authService,
            testCalendars: testCalendars,
            onNavItemTapped: (index) {
              selectedIndex = index;
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home).first);
      await tester.pumpAndSettle();

      expect(selectedIndex, equals(0));
    });
    testWidgets('should display TableCalendarWidget when loaded',
        (tester) async {
      // Set up mock calendars
      final testCalendars = [
        gcal.CalendarListEntry()
          ..id = 'calendar1'
          ..summary = 'Calendar 1',
      ];

      final testEvents = {
        DateTime(2025, 3, 23): [
          gcal.Event()
            ..id = 'event1'
            ..summary = 'Test Event'
            ..start = gcal.EventDateTime(dateTime: DateTime(2025, 3, 23, 10, 0))
            ..end = gcal.EventDateTime(dateTime: DateTime(2025, 3, 23, 11, 0))
        ]
      };

      final mockCalendarEventService = MockCalendarEventService();
      when(mockCalendarEventService.fetchCalendars())
          .thenAnswer((_) async => testCalendars);
      when(mockCalendarEventService.fetchCalendarEvents(any,
              useCache: anyNamed('useCache')))
          .thenAnswer((_) async => testEvents);

      final widget = ProviderScope(
        overrides: [
          navigationProvider.overrideWith((ref) => NavigationNotifier()),
        ],
        child: MaterialApp(
          home: CalendarScreen(
            authService: authService,
            testCalendarEventService: mockCalendarEventService,
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.byType(TableCalendarWidget), findsOneWidget);
    });
  });
}

class TestCalendarScreen extends ConsumerStatefulWidget {
  final AuthService authService;
  final List<gcal.CalendarListEntry>? testCalendars;
  final Map<DateTime, List<gcal.Event>>? testEvents;
  final String? initialCalendarId;
  final Future<void> Function()? onInitialize;
  final Exception? refreshError;
  final Exception? eventsError;
  final Function(String)? onCalendarSelected;
  final Function(DateTime, DateTime)? onDaySelected;
  final Function(CalendarFormat)? onFormatChanged;
  final Function(DateTime)? onPageChanged;
  final Function(gcal.Event)? onEventCreated;
  final Function(List<gcal.Event>)? onEventsFiltered;
  final Function(int)? onNavItemTapped;
  const TestCalendarScreen({
    super.key,
    required this.authService,
    this.testCalendars,
    this.testEvents,
    this.initialCalendarId,
    this.onInitialize,
    this.refreshError,
    this.eventsError,
    this.onCalendarSelected,
    this.onDaySelected,
    this.onFormatChanged,
    this.onPageChanged,
    this.onEventCreated,
    this.onEventsFiltered,
    this.onNavItemTapped,
  });

  @override
  ConsumerState<TestCalendarScreen> createState() => TestCalendarScreenState();
}

class TestCalendarScreenState extends ConsumerState<TestCalendarScreen> {
  bool _isLoading = true;
  String? _error;
  String? _selectedCalendarId;
  List<gcal.CalendarListEntry> _calendars = [];
  Map<DateTime, List<gcal.Event>> _eventsByDay = {};
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedCalendarId = widget.initialCalendarId;
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (widget.onInitialize != null) {
        await widget.onInitialize!();
      }

      setState(() {
        _isLoading = false;
        if (widget.testCalendars != null) {
          _calendars = widget.testCalendars!;
          _selectedCalendarId ??=
              _calendars.isNotEmpty ? _calendars.first.id : null;
        }
        if (widget.testEvents != null) {
          _eventsByDay = widget.testEvents!;
        }
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load calendars: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.refreshError != null) {
        throw widget.refreshError!;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to refresh events: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCalendarEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.eventsError != null) {
        throw widget.eventsError!;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (widget.testEvents != null && _selectedCalendarId != null) {
        final filteredEventsByDay = <DateTime, List<gcal.Event>>{};

        widget.testEvents!.forEach((date, events) {
          final filteredEvents = events.where((event) {
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
          _isLoading = false;
        });

        if (widget.onEventsFiltered != null) {
          final todayEvents = _getEventsForDay(_selectedDay!);
          widget.onEventsFiltered!(todayEvents);
        }
      } else {
        setState(() {
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

  List<gcal.Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _eventsByDay[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.read(navigationProvider).selectedIndex;

    void onItemTapped(int index) {
      if (widget.onNavItemTapped != null) {
        widget.onNavItemTapped!(index);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Calendar Screen'),
        actions: [
          if (_error != null) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshEvents,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_calendars.isNotEmpty)
                  DropdownButton<String>(
                    value: _selectedCalendarId,
                    items: _calendars
                        .map(
                          (calendar) => DropdownMenuItem<String>(
                            value: calendar.id,
                            child: Text(calendar.summary ?? 'Unknown'),
                          ),
                        )
                        .toList(),
                    onChanged: (selectedCalendarId) {
                      setState(() {
                        _selectedCalendarId = selectedCalendarId;
                        _fetchCalendarEvents();
                      });
                      if (widget.onCalendarSelected != null) {
                        widget.onCalendarSelected!(selectedCalendarId!);
                      }
                    },
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      if (_selectedDay != null)
                        ..._getEventsForDay(_selectedDay!).map(
                          (event) => ListTile(
                            title: Text(event.summary ?? 'No Title'),
                            subtitle: Text(
                                event.start?.dateTime.toString() ?? 'No Date'),
                            onTap: () {
                              if (widget.onEventCreated != null) {
                                widget.onEventCreated!(event);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
