import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis/calendar/v3.dart';
import '../repositories/auth_repository.dart';

/// A service class for handling Google Calendar operations.
///
/// This service provides methods to **fetch, create, update, and delete**
/// calendar events using the **Google Calendar API**.
/// It requires an [AuthRepository] for authentication purposes.
///
/// ## Usage:
/// ```dart
/// final calendarService = CalendarService(authRepository);
/// final events = await calendarService.fetchEvents();
/// final calendars = await calendarService.fetchCalendars();
/// ```
///
/// ## Methods:
/// - [fetchEvents] - Retrieves a list of events from the **primary calendar**.
/// - [fetchCalendars] - Retrieves a list of available calendars for the authenticated user.
/// - [createEvent] - Creates a new event in the specified calendar.
/// - [updateEvent] - Updates an existing event in the specified calendar.
/// - [deleteEvent] - Deletes an event from the specified calendar.
///
/// ## Exceptions:
/// - If the user is not authenticated, the methods return **empty lists or null values**.
/// - API errors may be thrown if there are permission issues or invalid parameters.
///
/// ## Notes:
/// - Ensure the user is **authenticated** before calling any method.
class CalendarService {
  final AuthRepository _authRepository;
  final CalendarApi Function(auth.AuthClient) _calendarApiProvider;

  /// Constructor for [CalendarService].
  ///
  /// Requires an instance of [AuthRepository] to handle authentication.
  CalendarService(this._authRepository,
      {CalendarApi Function(auth.AuthClient)? calendarApiProvider})
      : _calendarApiProvider =
            calendarApiProvider ?? ((authClient) => CalendarApi(authClient));

  /// Fetches a list of events from the **primary calendar**.
  ///
  /// This method retrieves events from the user's primary Google Calendar.
  ///
  /// ## Returns:
  /// - A `List<Event>` containing the user's scheduled events.
  /// - Returns an **empty list** if authentication fails or no events are found.
  ///
  /// ## Example:
  /// ```dart
  /// final events = await calendarService.fetchEvents();
  /// ```
Future<List<Event>> fetchEvents() async {
    final auth.AuthClient? authClient = await _authRepository.getAuthClient();
    if (authClient == null) return [];

    final calendar = _calendarApiProvider(authClient);
    final events = await calendar.events.list('primary');

    return events.items ?? [];
  }


  /// Fetches a list of available calendars for the authenticated user.
  ///
  /// ## Returns:
  /// - A `List<CalendarListEntry>` containing the available calendars.
  /// - Returns an **empty list** if authentication fails or no calendars are found.
  ///
  /// ## Example:
  /// ```dart
  /// final calendars = await calendarService.fetchCalendars();
  /// ```
Future<List<CalendarListEntry>> fetchCalendars() async {
    final auth.AuthClient? authClient = await _authRepository.getAuthClient();
    if (authClient == null) return [];

    final calendar = _calendarApiProvider(authClient);
    final calendars = await calendar.calendarList.list();

    return calendars.items ?? [];
  }

  /// Creates a new event in the specified Google Calendar.
  ///
  /// ## Parameters:
  /// - [calendarId]: The ID of the calendar where the event should be created.
  /// - [event]: The `Event` object containing the event details.
  ///
  /// ## Returns:
  /// - The newly created `Event` if successful.
  /// - Returns `null` if authentication fails or the event could not be created.
  ///
  /// ## Example:
  /// ```dart
  /// final newEvent = Event()
  ///   ..summary = "Meeting with Team"
  ///   ..start = EventDateTime(dateTime: DateTime.now().add(Duration(days: 1)))
  ///   ..end = EventDateTime(dateTime: DateTime.now().add(Duration(days: 1, hours: 1)));
  ///
  /// final createdEvent = await calendarService.createEvent('primary', newEvent);
  /// ```
  Future<Event?> createEvent(String calendarId, Event event) async {
    final auth.AuthClient? authClient = await _authRepository.getAuthClient();
    if (authClient == null) return null;

    final calendar = _calendarApiProvider(authClient);
    return await calendar.events.insert(event, calendarId);
  }

  /// Updates an existing event in the specified Google Calendar.
  ///
  /// ## Parameters:
  /// - [calendarId]: The ID of the calendar containing the event.
  /// - [eventId]: The ID of the event to be updated.
  /// - [updatedEvent]: The modified `Event` object.
  ///
  /// ## Returns:
  /// - The updated `Event` if successful.
  /// - Returns `null` if authentication fails or the update fails.
  ///
  /// ## Example:
  /// ```dart
  /// final updatedEvent = Event()
  ///   ..summary = "Updated Meeting"
  ///   ..start = EventDateTime(dateTime: DateTime.now().add(Duration(days: 2)))
  ///   ..end = EventDateTime(dateTime: DateTime.now().add(Duration(days: 2, hours: 1)));
  ///
  /// final event = await calendarService.updateEvent('primary', 'eventId123', updatedEvent);
  /// ```
  Future<Event?> updateEvent(
      String calendarId, String eventId, Event updatedEvent) async {
    final auth.AuthClient? authClient = await _authRepository.getAuthClient();
    if (authClient == null) return null;

    final calendar = _calendarApiProvider(authClient);
    return await calendar.events.update(updatedEvent, calendarId, eventId);
  }
  /// Deletes an event from the specified Google Calendar.
  ///
  /// ## Parameters:
  /// - [calendarId]: The ID of the calendar from which the event should be deleted.
  /// - [eventId]: The ID of the event to be removed.
  ///
  /// ## Example:
  /// ```dart
  /// await calendarService.deleteEvent('primary', 'eventId123');
  /// ```
  Future<void> deleteEvent(String calendarId, String eventId) async {
    final auth.AuthClient? authClient = await _authRepository.getAuthClient();
    if (authClient == null) return;

    final calendar = _calendarApiProvider(authClient);
    await calendar.events.delete(calendarId, eventId);
  }
}
