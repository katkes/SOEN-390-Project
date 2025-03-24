import 'package:flutter/material.dart';
import 'package:soen_390/models/places.dart';

/// A card widget that displays summary information about a [Place].
///
/// Shows the place's name, types, rating, open status, and an optional thumbnail
/// fetched using the Google Places API.
class POICard extends StatelessWidget {
  /// The [Place] instance containing data to be displayed.
  final Place place;

  /// Google Places API key used to retrieve the thumbnail image for the place.
  final String apiKey;

  /// Constructs a [POICard] widget.
  ///
  /// Requires a [place] and a valid [apiKey] for retrieving thumbnails.
  const POICard({
    required this.place,
    required this.apiKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = place.thumbnailPhotoUrl(apiKey);

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: thumbnailUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  thumbnailUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
              )
            : const Icon(Icons.place, size: 40),
        title: Text(place.name),
        subtitle: Text(
          '${place.formattedTypes()} • ${place.ratingSummary()}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(place.openStatus()),
      ),
    );
  }
}
