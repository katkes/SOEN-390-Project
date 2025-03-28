import 'package:flutter/material.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/outdoor_poi_detail_widgets.dart';

class PoiRatingRow extends StatelessWidget {
  final double? rating;
  final String? priceRange;

  const PoiRatingRow({
    super.key,
    required this.rating,
    required this.priceRange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (rating != null) ...[
            buildRatingStars(rating!),
            const SizedBox(width: 8),
            Text(
              rating!.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (priceRange != null)
            Text(
              priceRange!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
