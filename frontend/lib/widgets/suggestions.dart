import 'package:flutter/material.dart';

class SuggestionsPopup extends StatefulWidget {
  final Function(String) onSelect;

  SuggestionsPopup({super.key, required this.onSelect});

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
            TextField(
              controller: _searchController,
              onChanged: _filterSuggestions,
              decoration: const InputDecoration(
                labelText: "Enter an address",
                hintText: "Type address or select from list...",
                border: OutlineInputBorder(),
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
