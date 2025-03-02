import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SuggestionsPopup extends StatefulWidget {
  final Function(String) onSelect;

  const SuggestionsPopup({super.key, required this.onSelect});

  @override
  SuggestionsPopupState createState() => SuggestionsPopupState();
}

class SuggestionsPopupState extends State<SuggestionsPopup> {
  final TextEditingController _searchController = TextEditingController();

  List<String> suggestions = [
    "Restaurant",
    "Fast Food",
    "Coffee",
    "Dessert",
    "Shopping",
    "Bar"
  ];
  List<String> filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    filteredSuggestions = suggestions;

  
  }
  

  void _filterSuggestions(String input) {
    setState(() {
      filteredSuggestions = suggestions
          .where((suggestion) =>
              suggestion.toLowerCase().contains(input.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             GooglePlacesAutoCompleteTextFormField(
              textEditingController: _searchController,
              googleAPIKey: dotenv.env['GOOGLE_PLACES_API_KEY'] ?? "",
              debounceTime: 400, 
              countries: ["ca"], 
              fetchCoordinates: true, 
              onPlaceDetailsWithCoordinatesReceived: (prediction) {
                print("Coordinates: (${prediction.lat}, ${prediction.lng})");
                widget.onSelect(prediction.description ?? "");
              },
              onSuggestionClicked: (prediction) {
                _searchController.text = prediction.description ?? "";
                _searchController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description?.length ?? 0));
                Navigator.pop(context);
              },
              onChanged: (input) {
           
                _filterSuggestions(input);
              },
              decoration: InputDecoration(
                hintText: "Type address...", 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredSuggestions[index]),
                    onTap: () {
                      widget.onSelect(filteredSuggestions[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  widget.onSelect(_searchController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Use this Address"),
            ),
          ],
        ),
      ),
    );
  }
}
