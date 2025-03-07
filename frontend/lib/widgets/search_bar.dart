/// A custom search bar widget that expands and collapses when tapped.
///
/// The [SearchBarWidget] contains a [TextField] for user input. It expands
/// when focused and collapses when unfocused. The widget uses an
/// [AnimatedContainer] to animate the expansion and collapse.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/services/map_service.dart';
import 'package:latlong2/latlong.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(LatLng)? onLocationFound;
  final Function(LatLng)? onBuildingSelected;
  final Function(String)? onCampusSelected; // New callback to pass campus to CampusSwitch

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onLocationFound,
    this.onBuildingSelected,
    this.onCampusSelected,  // Accept campus selection callback
  });

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  bool isExpanded = false;
  final FocusNode _focusNode = FocusNode();
  final MapService _mapService = MapService();
  List<String> _suggestions = [];

  String? campus; // To store the campus associated with the building

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
      final buildingDetails = await _mapService.searchBuildingWithDetails(query);

      if (buildingDetails != null) {
        final location = buildingDetails['location'] as LatLng;
        widget.onLocationFound?.call(location);
        widget.onBuildingSelected?.call(location);

        campus = await _mapService.findCampusForBuilding(query);
        if(campus == "LOY"){
          campus = "Loyola";
        }
        debugPrint("Building belongs to: ${campus ?? 'Unknown'}");

        // Pass the campus value to CampusSwitch via the callback
        if (campus != null) {
          widget.onCampusSelected?.call(campus!);  // Notify the CampusSwitch widget of the campus
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Building not found")),
          );
        }
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
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
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
                      color: Colors.black.withAlpha(64),
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
                          decoration: const InputDecoration(
                            hintText: 'Search for Building',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(77, 0, 0, 0),
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
            if (isExpanded && _suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 240,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(63),
                      blurRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                      onTap: () {
                        debugPrint("Tapped suggestion: $suggestion");
                        setState(() {
                          widget.controller.text = suggestion;
                          _suggestions.clear();
                        });

                        _performSearch(suggestion);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            _focusNode.unfocus();
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

