import 'package:flutter/material.dart';

/// A widget that displays a selectable list of POI (Point of Interest) types.
///
/// Each type is represented as a button, and selecting one triggers the [onTypeSelected] callback.
class POITypeSelector extends StatelessWidget {
  /// Callback when a type is selected. Provides the selected type as a [String].
  final ValueChanged<String> onTypeSelected;

  /// List of POI types to display. Can be customized for different use cases.
  final List<String> types;

  /// Creates a [POITypeSelector] widget.
  ///
  /// [onTypeSelected] is required. [types] defaults to a common set of POI types if not provided.
  const POITypeSelector({
    required this.onTypeSelected,
    this.types = const [
      'restaurant',
      'store',
      'hospital',
      'bank',
      'transit_station',
      'lodging',
      'movie_theater',
      'park',
      'church',
      'school',
      'local_government_office',
      'car_repair',
      'beauty_salon',
      'tourist_attraction',
    ],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: types.map((type) {
        return ElevatedButton(
          onPressed: () => onTypeSelected(type),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: Text(
            type.replaceAll('_', ' ').toUpperCase(),
          ),
        );
      }).toList(),
    );
  }
}
