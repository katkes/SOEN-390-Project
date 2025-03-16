import 'package:flutter/material.dart';

/// This file contains a collection of reusable widgets to display detailed information about a location
/// It includes widgets for:
///   - Displaying chips with labels and colors
///   - Formatting price range information
///   - Rendering rating stars based on a numerical rating
///   - Showing expandable descriptions with "Read more/Show less" functionality
///   - Presenting information sections for address, contact phone, and website
///   - Displaying opening hours in a day-wise format
///   - Listing amenities using chip widgets
/// These widgets are intended to be used within a larger application to provide a consistent and informative user interface for displaying location details

// Reusable chip widget
Widget buildChip(String label, Color color) {
  return Chip(
    label: Text(label),
    backgroundColor: color,
    labelStyle: const TextStyle(color: Colors.black87),
    visualDensity: VisualDensity.compact,
  );
}

// Price range formatting utility
String getPriceRangeString(Map<String, dynamic> priceRange) {
  if (priceRange.containsKey('symbol')) {
    return priceRange['symbol'] as String;
  } else if (priceRange.containsKey('range')) {
    return priceRange['range'] as String;
  }
  return '';
}

// Rating stars widget
Widget buildRatingStars(double rating) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) {
      if (index < rating.floor()) {
        return const Icon(Icons.star, color: Colors.amber, size: 20);
      } else if (index < rating.ceil() && rating.floor() != rating.ceil()) {
        return const Icon(Icons.star_half, color: Colors.amber, size: 20);
      } else {
        return const Icon(Icons.star_border, color: Colors.amber, size: 20);
      }
    }),
  );
}

// Expandable description widget to not show full description by default
Widget buildExpandableDescription(
  String description,
  bool showFullDescription,
  VoidCallback onToggle,
  BuildContext context,
) {
  final maxLines = showFullDescription ? null : 3;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        description,
        maxLines: maxLines,
        overflow:
            showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
      if (description.length > 150)
        TextButton(
          onPressed: onToggle,
          child: Text(
            showFullDescription ? 'Show less' : 'Read more',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
    ],
  );
}

// Information section widget for address, contact phone, and website
Widget buildInfoSection(
  String? address,
  String? contactPhone,
  String? website,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Address
        if (address != null)
          buildInfoRow(
            Icons.location_on,
            address,
            context: context,
          ),

        // Phone number
        if (contactPhone != null)
          buildInfoRow(
            Icons.phone,
            contactPhone,
            context: context,
          ),

        // Website
        if (website != null)
          buildInfoRow(
            Icons.language,
            website,
            context: context,
          ),
      ],
    ),
  );
}

// Info row widget
Widget buildInfoRow(
  IconData icon,
  String text, {
  VoidCallback? onTap,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: onTap != null
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Opening hours section widget for displaying day-wise hours
Widget buildOpeningHoursSection(Map<String, String> openingHours) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...openingHours.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(entry.value),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}

// Amenities section widget for displaying a list of amenities
Widget buildAmenitiesSection(List<String> amenities) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: amenities.map((amenity) {
            return Chip(
              label: Text(amenity),
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ],
    ),
  );
}
