import 'package:flutter/material.dart';
import 'package:soen_390/services/map_service.dart';

/// A text field that allows the user to search for a building by name.
/// The user can select a building from a list of suggestions.
/// The user can also enter a building name manually.
class BuildingSearchField extends StatefulWidget {
  final void Function(String buildingName)? onSelected;
  final String? initialValue;
  final MapService? mapService;
  const BuildingSearchField(
      {super.key, this.onSelected, this.initialValue, this.mapService});

  @override
  State<BuildingSearchField> createState() => _BuildingSearchFieldState();
}

class _BuildingSearchFieldState extends State<BuildingSearchField> {
  final TextEditingController controller = TextEditingController();

  List<String> suggestions = [];
  bool _isLoading = false;
  late MapService mapService;
  @override
  void initState() {
    super.initState();
    mapService = widget.mapService ?? MapService();
    if (widget.initialValue != null) {
      controller.text = widget.initialValue!;
    }
  }

  Future<void> updateSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await mapService.getBuildingSuggestions(input);

      if (!mounted) return;

      setState(() {
        suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;

        suggestions = ["Error loading suggestions"];
      });

      print("Error fetching building suggestions");
    }
  }

  void selectBuilding(String building) {
    controller.text = building;
    setState(() {
      suggestions = [];
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
            key: const Key('building_search_field'),
            controller: controller,
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
                if (controller.text == value) {
                  updateSuggestions(value);
                }
              });
            },
          ),
          if (suggestions.isNotEmpty)
            Container(
              key: const Key('suggestions_list'),
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
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: Key('suggestion_$index'),
                    dense: true,
                    title: Text(suggestions[index]),
                    onTap: () => selectBuilding(suggestions[index]),
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
    controller.dispose();
    super.dispose();
  }
}
