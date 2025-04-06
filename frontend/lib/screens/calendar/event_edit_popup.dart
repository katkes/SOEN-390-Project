import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:intl/intl.dart';
import 'package:soen_390/services/calendar_service.dart';
import 'calendar_event_service.dart';
import '../../utils/building_search.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/screens/indoor/mappedin_map_controller.dart';
import 'package:soen_390/screens/indoor/mappedin_map_screen.dart';
import 'dart:async';

/// This widget displays a popup dialog for editing an event.
/// The user can edit the event title, location, description, start time, and end time.
/// The user can also delete the event.
/// The widget uses the [CalendarService] to update and delete events.
/// The widget uses the [CalendarEventService] to fetch and group calendar events by date.
//test comment
class EventEditPopup extends StatefulWidget {
  final gcal.Event event;
  final CalendarService calendarService;
  final VoidCallback? onEventUpdated;
  final VoidCallback? onEventDeleted;
  final CalendarEventService calendarEventService;
  final String calendarId;

  const EventEditPopup({
    super.key,
    required this.event,
    required this.calendarService,
    this.onEventUpdated,
    this.onEventDeleted,
    required this.calendarEventService,
    required this.calendarId,
  });

  @override
  EventEditPopupState createState() => EventEditPopupState();
}

class EventEditPopupState extends State<EventEditPopup> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
  late TextEditingController classroomController;
  late MappedinMapController mappedinController;
  late DateTime _startDate;
  late DateTime _endDate;

  bool _isUpdating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.summary);
    locationController = TextEditingController();
    mappedinController = MappedinMapController();
    descriptionController =
        TextEditingController(text: widget.event.description);
    _startDate = widget.event.start?.dateTime ?? DateTime.now();
    _endDate = widget.event.end?.dateTime ??
        DateTime.now().add(const Duration(hours: 1));

    final locationParts = (widget.event.location ?? '').split(', ');
    final building = locationParts.isNotEmpty ? locationParts.first : '';
    final classroom = locationParts.length > 1 ? locationParts[1] : '';

    locationController.text = building;
    classroomController = TextEditingController(text: classroom);
  }

  /// Opens the Mappedin map screen.
  Future<void> openMappedinMap() async {
    final completer = Completer<void>();

    // Start navigation without waiting for it to complete
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MappedinMapScreen(
          controller: mappedinController,
          onWebViewReady: () {
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        ),
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Event',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed:
                          _isDeleting ? null : () => confirmDelete(context),
                    ),
                  ],
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                BuildingSearchField(
                  initialValue: locationController.text,
                  onSelected: (selectedBuilding) {
                    locationController.text = selectedBuilding;
                  },
                ),
                TextField(
                  controller: classroomController,
                  decoration: const InputDecoration(labelText: 'Classroom'),
                ),
                ListTile(
                  title: const Text("Start Time"),
                  subtitle:
                      Text(DateFormat('yyyy-MM-dd HH:mm').format(_startDate)),
                  onTap: () => _selectDateTime(context, isStartTime: true),
                ),
                ListTile(
                  title: const Text("End Time"),
                  subtitle:
                      Text(DateFormat('yyyy-MM-dd HH:mm').format(_endDate)),
                  onTap: () => _selectDateTime(context, isStartTime: false),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _updateEvent,
                      child: _isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Update"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // TODO: 7.1.6 Add navigation logic to next class
                        final messenger = ScaffoldMessenger.of(context);
                        // First open the map screen and wait for it to be ready
                        await openMappedinMap();
                        final success = await mappedinController
                            .navigateToRoom(classroomController.text);
                        if (!success) {
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Failed to navigate to H813')),
                          );
                        }
                      },
                      icon: Icon(Icons.directions_walk,
                          color: appTheme.colorScheme.onPrimary),
                      label: const Text("Go Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appTheme.primaryColor,
                        foregroundColor: appTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context,
      {required bool isStartTime}) async {
    final initialDate = isStartTime ? _startDate : _endDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    if (context.mounted) {
      final newDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        if (isStartTime) {
          _startDate = newDateTime;
        } else {
          _endDate = newDateTime;
        }
      });
    }
  }

  Future<void> _updateEvent() async {
    setState(() {
      _isUpdating = true;
    });

    final updatedEvent = gcal.Event()
      ..summary = titleController.text
      ..location = '${locationController.text}, ${classroomController.text}'
      ..description = descriptionController.text
      ..start = gcal.EventDateTime(dateTime: _startDate)
      ..end = gcal.EventDateTime(dateTime: _endDate);

    try {
      await widget.calendarService.updateEvent(
        widget.calendarId,
        widget.event.id!,
        updatedEvent,
      );

      widget.onEventUpdated?.call();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update event: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _isDeleting ? null : () => _handleDelete(),
            child: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.red),
                  )
                : const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    if (!mounted) return;

    Navigator.of(context).pop();
    setState(() {
      _isDeleting = true;
    });

    try {
      await widget.calendarService.deleteEvent(
        widget.calendarId,
        widget.event.id!,
      );

      widget.onEventDeleted?.call();

      if (mounted) {
        Navigator.of(context).pop(); // Close the edit dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete event: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    classroomController.dispose();

    super.dispose();
  }
}
