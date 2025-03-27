import 'package:flutter/material.dart';
import 'package:soen_390/models/outdoor_poi.dart';

class PoiDetailAppBar extends StatelessWidget {
  final PointOfInterest poi;
  final VoidCallback? onBack;

  const PoiDetailAppBar({super.key, required this.poi, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).primaryColor,
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          poi.name,
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
        background: poi.imageUrl != null
            ? Image.network(
                poi.imageUrl!,
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
        onPressed: onBack ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}
