import 'package:flutter/material.dart';
import 'package:soen_390/models/review.dart';
import 'package:soen_390/widgets/review_card.dart';

class PoiReviewsSection extends StatelessWidget {
  final List<Review>? reviews;

  const PoiReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews == null || reviews!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...reviews!.map((review) => ReviewCard(review: review)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
