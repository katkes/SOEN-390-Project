import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'building_search.dart';

/// This file contains the EventCreationPopup widget which is used to create a new event.
/// The widget is a dialog that allows the user to input the event name, building, classroom, date, and time.
/// The user can select the building from a list of suggestions using the BuildingSearchField widget.
/// The user can also enter the building name manually.
/// The user can select the date and time using the date and time pickers.
/// The user can save the event by clicking the save button.
class EventCreationPopup extends StatefulWidget {
  final void Function(String name, String building, String classroom,
      TimeOfDay time, DateTime day, String? recurrenceFrequency) onSave;
  const EventCreationPopup({super.key, required this.onSave});

  @override
  State<EventCreationPopup> createState() => _EventCreationPopupState();
}

class _EventCreationPopupState extends State<EventCreationPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _classroomController = TextEditingController();
  String? _selectedBuilding;
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  String? _recurrenceFrequency;
  final List<String> recurrenceOptions = ["None", "Daily", "Weekly", "Monthly"];

  Future<void> _pickTime() async {
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _selectedBuilding != null &&
        _selectedTime != null &&
        _selectedDate != null) {
      widget.onSave(
        _eventNameController.text.trim(),
        _selectedBuilding ?? "Unknown",
        _classroomController.text.trim(),
        _selectedTime!,
        _selectedDate!,
        _recurrenceFrequency,
      );
      Navigator.of(context).pop();
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create New Event",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _eventNameController,
                          decoration:
                              const InputDecoration(labelText: "Event Name"),
                          validator: (value) =>
                              value?.isEmpty ?? true ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        // Building search field
                        BuildingSearchField(
                          initialValue: _selectedBuilding,
                          onSelected: (building) =>
                              setState(() => _selectedBuilding = building),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _classroomController,
                          decoration:
                              const InputDecoration(labelText: "Classroom"),
                          validator: (value) => value == null || value.isEmpty
                              ? "Required"
                              : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : "Pick a date"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time),
                          label: Text(_selectedTime != null
                              ? _selectedTime!.format(context)
                              : "Pick a time"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _recurrenceFrequency,
                          decoration:
                              const InputDecoration(labelText: "Recurrence"),
                          items: recurrenceOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _recurrenceFrequency = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Save"),
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
}
