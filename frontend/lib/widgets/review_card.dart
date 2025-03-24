import 'package:flutter/material.dart';
import '../models/review.dart';

/// A widget that displays a review inside a styled card layout.
///
/// The [ReviewCard] presents the reviewer's avatar, name, relative time of the review,
/// star rating, and review text in a neatly arranged UI. It is designed to be used
/// in lists or detail screens where user reviews are shown.
///
/// Example usage:
/// ```dart
/// ReviewCard(review: myReviewObject);
/// ```
///
/// Requires a [Review] object which contains the necessary information
/// like author name, profile photo URL, rating, time description, and text.
class ReviewCard extends StatelessWidget {
  /// The [Review] object containing all the data to be displayed in the card.
  final Review review;

  /// Creates a [ReviewCard] widget.
  ///
  /// The [review] parameter must not be null and is required.
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Displays the reviewer's profile photo, name, time, and star rating.
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(review.profilePhotoUrl),
              ),
              title: Text(
                review.authorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(review.relativeTimeDescription),

              /// Displays star icons based on the [review.rating].
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  review.rating,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Displays the text of the review.
            Text(
              review.text,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
