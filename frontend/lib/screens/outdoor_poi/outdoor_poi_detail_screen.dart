/// This file defines the `PoiDetailScreen` widget, which displays detailed information about a Point of Interest (POI).
///
/// It includes sections for:
///   - Displaying the POI's image and name in the app bar
///   - Showing category and cuisine information using chip widgets
///   - Presenting rating stars and price range
///   - Displaying an expandable description with "Read more/Show less" functionality
///   - Showing contact information (address, phone, website)
///   - Displaying opening hours
///   - Listing amenities
///   - Displaying user reviews
///
/// This screen provides an interactive and informative view for users to explore the details of a POI,
/// including visual, textual, and user-generated content.

library;

import 'package:flutter/material.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/widgets/poi_description_section.dart';
import 'package:soen_390/widgets/poi_detail_app_bar.dart';
import 'package:soen_390/widgets/poi_rating_row.dart';
import 'package:soen_390/widgets/poi_reviews_section.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/outdoor_poi_detail_widgets.dart';
import 'package:soen_390/widgets/set_destination_button.dart';

/// A stateful widget that displays detailed information about a specific
/// [PointOfInterest] object.
///
/// The screen includes a scrollable layout with an image header (SliverAppBar),
/// chips for category/cuisine, rating stars, price range, description with expand/collapse,
/// contact information, opening hours, amenities, and user reviews.
///
/// The screen can also execute an optional callback [onBack] when the back button is pressed.
class PoiDetailScreen extends StatefulWidget {
  /// The Point of Interest (POI) whose details are being displayed.
  final PointOfInterest poi;

  /// An optional callback to be invoked when the user presses the back button.
  /// If null, it will default to popping the navigation stack.
  final VoidCallback? onBack;

  /// Constructs a [PoiDetailScreen] with the required [poi] and optional [onBack] callback.
  final void Function(String name, double lat, double lng)? onSetDestination;

  const PoiDetailScreen({
    super.key,
    required this.poi,
    this.onBack,
    this.onSetDestination,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PoiDetailScreenState createState() => _PoiDetailScreenState();
}

/// State class for [PoiDetailScreen] which manages the UI and internal state,
/// such as toggling between full/short descriptions.
class _PoiDetailScreenState extends State<PoiDetailScreen> {
  /// Tracks whether the full description text is being shown.
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// Displays a collapsible AppBar with the POI's name and image.
          PoiDetailAppBar(poi: widget.poi, onBack: widget.onBack),

          /// Main content list: includes chips, rating, description, contact, hours, amenities, and reviews.
          SliverList(
            delegate: SliverChildListDelegate([
              // Category and cuisine chips
              if (widget.poi.category != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child:
                      buildChip(widget.poi.category!, const Color(0xFFCCE3E4)),
                ),

              // Rating stars and price range
              PoiRatingRow(
                rating: widget.poi.rating,
                priceRange: widget.poi.priceRange,
              ),

              // Navigate to Waypoint Selection
              SetDestinationButton(
                name: widget.poi.name,
                latitude: widget.poi.latitude,
                longitude: widget.poi.longitude,
              ),

              // Expandable Description
              PoiDescriptionSection(
                description: widget.poi.description,
                showFull: _showFullDescription,
                onToggle: () {
                  setState(() {
                    _showFullDescription = !_showFullDescription;
                  });
                },
              ),

              // Contact Info: Address, Phone, Website
              buildInfoSection(
                widget.poi.address,
                widget.poi.contactPhone,
                widget.poi.website,
                context,
              ),

              // Opening Hours
              if (widget.poi.openingHours != null &&
                  widget.poi.openingHours!.isNotEmpty)
                buildOpeningHoursSection(widget.poi.openingHours!),

              // Amenities
              if (widget.poi.amenities != null &&
                  widget.poi.amenities!.isNotEmpty)
                buildAmenitiesSection(widget.poi.amenities!),

              const SizedBox(height: 24),

              // Reviews
              PoiReviewsSection(reviews: widget.poi.reviews),
            ]),
          ),
        ],
      ),
    );
  }
}
