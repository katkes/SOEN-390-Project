class CalendarEvent {
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  CalendarEvent(
      {required this.title, required this.startTime, required this.endTime});

  factory CalendarEvent.fromGoogleEvent(dynamic event) {
    return CalendarEvent(
      title: event.summary ?? "No Title",
      startTime:
          DateTime.parse(event.start?.dateTime ?? event.start?.date ?? ""),
      endTime: DateTime.parse(event.end?.dateTime ?? event.end?.date ?? ""),
    );
  }
}
