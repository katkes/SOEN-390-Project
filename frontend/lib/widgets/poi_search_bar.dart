import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

/// A search bar widget for searching places using Google Places Autocomplete API.
///
/// Allows users to input a location manually or use their current location.
/// The widget fetches coordinates and passes them back via [onSearch] callback.
class POISearchBar extends StatelessWidget {
  /// Controller to manage the text input.
  final TextEditingController controller;

  /// Callback invoked when a place is selected with its [address], [latitude], and [longitude].
  final Function(String address, double latitude, double longitude) onSearch;

  /// Callback triggered when user presses the "Use Current Location" button.
  final VoidCallback onUseCurrentLocation;

  /// Google Places API Key (injected for better testability and separation of concerns).
  final String googleApiKey;

  /// Optional country restriction for place suggestions (default is Canada).
  final List<String> countries;

  /// Constructs a [POISearchBar] widget.
  ///
  /// [googleApiKey] must be a valid Google Places API Key.
  POISearchBar({
    required this.controller,
    required this.onSearch,
    required this.onUseCurrentLocation,
    required this.googleApiKey,
    this.countries = const ["ca"], // default to Canada
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GooglePlacesAutoCompleteTextFormField(
            textEditingController: controller,
            googleAPIKey: googleApiKey,
            debounceTime: 400,
            countries: countries,
            fetchCoordinates: true,
            onPlaceDetailsWithCoordinatesReceived: (prediction) {
              double lat = double.tryParse(prediction.lat.toString()) ?? 0.0;
              double lng = double.tryParse(prediction.lng.toString()) ?? 0.0;
              if (lat == 0.0 && lng == 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Failed to get valid location coordinates.")),
                );
                return;
              }

              String desc = prediction.description ?? '';

              print("Coordinates received: ($lat, $lng)");

              controller.text = desc;
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));

              onSearch(desc, lat, lng);
            },
            onSuggestionClicked: (prediction) {
              controller.text = prediction.description ?? '';
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));
            },
            decoration: InputDecoration(
              hintText: 'Enter location',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: onUseCurrentLocation,
        ),
      ],
    );
  }
}
