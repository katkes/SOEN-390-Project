import 'package:flutter/material.dart';

class SuggestionsPopup extends StatelessWidget {
  final Function(String) onSelect;

  SuggestionsPopup({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 365,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            _buildSuggestion(context, "Restaurant"),
            _buildSuggestion(context, "Fast Food"),
            _buildSuggestion(context, "Coffee"),
            _buildSuggestion(context, "Dessert"),
            _buildSuggestion(context, "Shopping"),
            _buildSuggestion(context, "Bar"),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestion(BuildContext context, String title) {
    return InkWell(
      onTap: () {
        onSelect(title);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.place, color: Color(0xFF912338)),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
