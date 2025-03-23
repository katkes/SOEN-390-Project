import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

/// A search bar widget for searching places using Google Places Autocomplete API.
///
/// Allows users to input a location manually or use their current location.
/// The widget fetches coordinates and passes them back via [onSearch] callback.
@immutable
class POISearchBar extends StatelessWidget {
  /// Controller for the search text field.
  final TextEditingController controller;

  /// Callback invoked with address and coordinates after search.
  final Function(String address, double latitude, double longitude) onSearch;

  /// Callback to trigger current location fetch. Expects a lat/lng callback.
  final Future<void> Function(Function(double lat, double lng) onCoordsObtained)
      onUseCurrentLocation;

  /// Google Places API Key for autocomplete.
  final String googleApiKey;

  /// List of country codes to restrict autocomplete search.
  final List<String> countries;

  /// Creates a [POISearchBar] widget.
  ///
  /// All parameters are required except [countries], which defaults to ['ca'].
  const POISearchBar({
    required this.controller,
    required this.onSearch,
    required this.onUseCurrentLocation,
    required this.googleApiKey,
    this.countries = const ["ca"],
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
                    content: Text("Failed to get valid location coordinates."),
                  ),
                );
                return;
              }

              String desc = prediction.description ?? '';
              controller.text = desc;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );

              onSearch(desc, lat, lng);
            },
            onSuggestionClicked: (prediction) {
              controller.text = prediction.description ?? '';
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            },
            decoration: InputDecoration(
              hintText: 'Enter location',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: () {
            controller.text = 'Getting location...';
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );

            onUseCurrentLocation((lat, lng) {
              controller.text = 'Current Location';
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
              onSearch('Current Location', lat, lng);
            });
          },
        ),
      ],
    );
  }
}
