import 'package:flutter/material.dart';
import 'package:soen_390/models/places.dart';
import 'package:soen_390/widgets/poi_card.dart';

/// A widget that displays a scrollable list of [Place] items using [POICard] widgets.
///
/// Each [POICard] is tappable, triggering the [onPlaceTap] callback when tapped.
/// If no places are available, a message indicating that no results were found is shown.
class POIListView extends StatelessWidget {
  /// The list of [Place] objects to display.
  final List<Place> places;

  /// API key used for fetching or displaying additional information such as images.
  final String apiKey;

  /// Callback function that is invoked when a user taps on a [Place] card.
  ///
  /// Typically used to navigate to a detail page or trigger an action with the selected place.
  final void Function(Place) onPlaceTap;

  /// Constructs a [POIListView] widget.
  ///
  /// Requires a list of [places], an [apiKey], and an [onPlaceTap] callback.
  const POIListView({
    required this.places,
    required this.apiKey,
    required this.onPlaceTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Display placeholder text when the list of places is empty.
    if (places.isEmpty) {
      return const Center(
        child: Text(
          'No places found.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Render the list of POI cards with separators.
    return ListView.separated(
      itemCount: places.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => onPlaceTap(places[index]),
        child: POICard(place: places[index], apiKey: apiKey),
      ),
      separatorBuilder: (context, index) => const Divider(height: 0),
    );
  }
}
