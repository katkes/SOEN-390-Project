import 'package:flutter/material.dart';

/// A customizable input-like widget used to display a location field with optional delete functionality.
///
/// The [LocationField] is typically used to show a selected location (e.g., start or destination)
/// in a form-like layout. Tapping the field triggers a selection callback,
/// and optionally, a delete icon allows the user to clear the input.
///
/// Example usage:
/// ```dart
/// LocationField(
///   text: selectedAddress,
///   placeholder: 'Select location',
///   onTap: () => openLocationPicker(),
///   onDelete: () => clearAddress(),
///   showDelete: true,
/// );
/// ```
class LocationField extends StatelessWidget {
  /// The text to display inside the field.
  ///
  /// If empty, the [placeholder] will be shown instead.
  final String text;

  /// The placeholder text shown when [text] is empty.
  final String placeholder;

  /// Callback triggered when the field is tapped.
  ///
  /// Typically used to open a location picker or search dialog.
  final VoidCallback onTap;

  /// Optional callback triggered when the delete icon is pressed.
  ///
  /// Only visible when [showDelete] is `true` and [text] is not empty.
  final VoidCallback? onDelete;

  /// Whether to show the delete icon (if [text] is not empty).
  final bool showDelete;

  /// Creates a [LocationField] widget.
  ///
  /// Parameters:
  /// - [text]: The current value to display in the field.
  /// - [placeholder]: A fallback label shown when [text] is empty.
  /// - [onTap]: Called when the user taps the field.
  /// - [onDelete]: Called when the delete icon is pressed (if visible).
  /// - [showDelete]: Enables or disables the delete icon visibility.
  const LocationField({
    super.key,
    required this.text,
    required this.placeholder,
    required this.onTap,
    this.onDelete,
    this.showDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text.isEmpty ? placeholder : text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showDelete && text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: onDelete,
              ),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
