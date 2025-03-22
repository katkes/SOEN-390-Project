import 'package:flutter/material.dart';
import 'package:soen_390/services/map_service.dart';

/// A text field that allows the user to search for a building by name.
/// The user can select a building from a list of suggestions.
/// The user can also enter a building name manually.
class BuildingSearchField extends StatefulWidget {
  final void Function(String buildingName)? onSelected;
  final String? initialValue;
  const BuildingSearchField({super.key, this.onSelected, this.initialValue});

  @override
  State<BuildingSearchField> createState() => _BuildingSearchFieldState();
}

class _BuildingSearchFieldState extends State<BuildingSearchField> {
  final TextEditingController _controller = TextEditingController();
  final MapService _mapService = MapService();
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  Future<void> updateSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _mapService.getBuildingSuggestions(input);

      if (!mounted) return;

      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _suggestions = ["Error loading suggestions"];
      });

      print("Error fetching building suggestions: $e");
    }
  }

  void selectBuilding(String building) {
    _controller.text = building;
    setState(() {
      _suggestions = [];
    });
    widget.onSelected?.call(building);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Building",
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : null,
            ),
            onChanged: (value) {
              // Debounce the API call
              Future.delayed(const Duration(milliseconds: 300), () {
                if (_controller.text == value) {
                  updateSuggestions(value);
                }
              });
            },
          ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    title: Text(_suggestions[index]),
                    onTap: () => selectBuilding(_suggestions[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
