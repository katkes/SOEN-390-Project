import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const SearchBarWidget({super.key, required this.controller, this.onChanged});

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  bool isExpanded = false;
  final FocusNode _focusNode = FocusNode();

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

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                curve: Curves.easeInOut, // Smooth animation
                width: isExpanded ? 280 : 58, // Expanding width
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
                    Icon(
                      Icons.search,
                      color: Colors.black
                          .withValues(red: 0, green: 0, blue: 0, alpha: 179),
                    ),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isExpanded ? 1.0 : 0.0, // Fade in/out animation
                          child: TextField(
                            focusNode: _focusNode,
                            controller: widget.controller,
                            onChanged: widget.onChanged,
                            decoration: InputDecoration(
                              hintText: 'Search',
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
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
