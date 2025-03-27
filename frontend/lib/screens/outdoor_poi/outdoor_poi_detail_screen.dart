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
import 'package:soen_390/widgets/review_card.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/outdoor_poi_detail_widgets.dart';

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

  Widget _buildReviewsSection() {
    if (widget.poi.reviews == null || widget.poi.reviews!.isEmpty) {
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
          ...widget.poi.reviews!.map((review) => ReviewCard(review: review)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
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
            widget.poi.description,
            _showFullDescription,
            () {
              setState(() {
                _showFullDescription = !_showFullDescription;
              });
            },
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildSetDestinationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.directions),
        label: const Text("Set Destination"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.pop(context, {
            'name': widget.poi.name,
            'lat': widget.poi.latitude,
            'lng': widget.poi.longitude,
          });
        },
      ),
    );
  }

  Widget _buildRatingRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (widget.poi.rating != null) ...[
            buildRatingStars(widget.poi.rating!),
            const SizedBox(width: 8),
            Text(
              widget.poi.rating!.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (widget.poi.priceRange != null)
            Text(
              widget.poi.priceRange!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.poi.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        background: widget.poi.imageUrl != null
            ? Image.network(
                widget.poi.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).primaryColor,
                    child: const Center(
                      child: Icon(
                        Icons.location_pin,
                        size: 64,
                        color: Color(0xFF912338),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: Theme.of(context).primaryColor,
                child: const Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 64,
                    color: Colors.white70,
                  ),
                ),
              ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// Displays a collapsible AppBar with the POI's name and image.
          _buildAppBar(context),

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
              _buildRatingRow(),

              // Navigate to Waypoint Selection
              _buildSetDestinationButton(),

              // Expandable Description
              _buildDescriptionSection(),

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
              _buildReviewsSection(),
            ]),
          ),
        ],
      ),
    );
  }
}
