import 'package:flutter/material.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/outdoor_poi_detail_widgets.dart';

class PoiDescriptionSection extends StatelessWidget {
  final String description;
  final bool showFull;
  final VoidCallback onToggle;

  const PoiDescriptionSection({
    super.key,
    required this.description,
    required this.showFull,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          buildExpandableDescription(
            description,
            showFull,
            onToggle,
            context,
          ),
        ],
      ),
    );
  }
}
