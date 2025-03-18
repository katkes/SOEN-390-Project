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

library;

import 'package:flutter/material.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/outdoor_poi_detail_widgets.dart';
import 'package:soen_390/screens/outdoor_poi/widgets/sample_data.dart';

class PoiDetailScreen extends StatefulWidget {
  final PointOfInterest poi;
  final VoidCallback? onBack;

  const PoiDetailScreen({
    super.key,
    required this.poi,
    this.onBack,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PoiDetailScreenState createState() => _PoiDetailScreenState();
}

class _PoiDetailScreenState extends State<PoiDetailScreen> {
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
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
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Category and cuisine
              if (widget.poi.category != null ||
                  (widget.poi.cuisine != null &&
                      widget.poi.cuisine!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      if (widget.poi.category != null)
                        buildChip(
                            widget.poi.category!, const Color(0xFFCCE3E4)),
                      const SizedBox(width: 8),
                      if (widget.poi.cuisine != null &&
                          widget.poi.cuisine!.isNotEmpty)
                        ...widget.poi.cuisine!.map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: buildChip(c, const Color(0xFFe9e3d3)),
                            )),
                    ],
                  ),
                ),

              // Rating and price range
              Padding(
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
                        getPriceRangeString(widget.poi.priceRange!),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),

              // Description
              Padding(
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
              ),

              // Contact info and address
              buildInfoSection(
                widget.poi.address,
                widget.poi.contactPhone,
                widget.poi.website,
                context,
              ),

              // Opening hours
              if (widget.poi.openingHours != null &&
                  widget.poi.openingHours!.isNotEmpty)
                buildOpeningHoursSection(widget.poi.openingHours!),

              // Amenities
              if (widget.poi.amenities != null &&
                  widget.poi.amenities!.isNotEmpty)
                buildAmenitiesSection(widget.poi.amenities!),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}

//TODO: This is for to see how the screen how it will look visually, this will be removed in the final version
// For testing purposes only, task 6.1.2
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POI Detail Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Theme.of(context).primaryColor,
        ).copyWith(
          primary: const Color(0xFF912338),
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PoiDetailPage(),
    );
  }
}
