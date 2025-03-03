/// A custom search bar widget that expands and collapses when tapped.
///
/// The [SearchBarWidget] contains a [TextField] for user input. It expands
/// when focused and collapses when unfocused. The widget uses an
/// [AnimatedContainer] to animate the expansion and collapse, and an
/// [AnimatedOpacity] to fade in and out the [TextField].
library;

import 'package:flutter/material.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:latlong2/latlong.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(LatLng)? onLocationFound;

  const SearchBarWidget({super.key, required this.controller, this.onLocationFound});

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  bool isExpanded = false;
  final FocusNode _focusNode = FocusNode();
  final MapService _mapService = MapService();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isExpanded = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      LatLng? location = await _mapService.searchBuilding(query);
      if (location != null) {
        debugPrint("Moving to location: $location");
        widget.onLocationFound?.call(location);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Building not found")),
        );
      }
    }
  }

  void _updateSuggestions(String query) async {
    if (query.isNotEmpty) {
      List<String> results = await _mapService.getBuildingSuggestions(query);
      setState(() {
        _suggestions = results;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 90),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                  if (isExpanded) {
                    _focusNode.requestFocus();
                  } else {
                    _focusNode.unfocus();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isExpanded ? 280 : 58,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(red: 0, green: 0, blue: 0, alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black87),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: widget.controller,
                          onChanged: _updateSuggestions,
                          onSubmitted: _performSearch,
                          decoration: InputDecoration(
                            hintText: 'Search for Building',
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(
                                  red: 0, green: 0, blue: 0, alpha: 77),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: -90,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isExpanded && _suggestions.isNotEmpty ? 1.0 : 0.0,
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(red: 0, green: 0, blue: 0, alpha: 0.25),
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _suggestions.map((suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      widget.controller.text = suggestion;
                      _performSearch(suggestion);
                      setState(() {
                        _suggestions = [];
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
