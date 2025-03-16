import 'package:flutter/material.dart';
import 'package:soen_390/models/outdoor_poi.dart';
import 'package:soen_390/screens/outdoor_poi/outdoor_poi_detail_screen.dart';

class PoiDetailPage extends StatelessWidget {
  const PoiDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Weinstein and Gavino's restaurant POI data
    final weinsteinAndGavinos = const PointOfInterest(
      id: 'w1',
      name: 'Weinstein & Gavino\'s',
      description: 'Housemade pasta, pizza & Italian standards in a 3-level place with a grand staircase & open kitchen.',
      imageUrl: 'https://514eats.com/img/spots/wienstein_gavinos_exterior.jpg',
      address: '1434 Crescent St, Montreal, QC H3G 2B6, Canada',
      contactPhone: '(514) 288-2231',
      website: 'www.weinsteinandgavinos.com',
      openingHours: {
        'Monday': '11:00 AM - 12:00 AM',
        'Tuesday': '11:00 AM - 12:00 AM',
        'Wednesday': '11:00 AM - 12:00 AM',
        'Thursday': '11:00 AM - 12:00 AM',
        'Friday': '11:00 AM - 12:00 AM',
        'Saturday': '11:00 AM - 12:00 AM',
        'Sunday': '11:00 AM - 12:00 AM',
      },
      amenities: [
        'Has outdoor seating',
        'Serves great cocktails',
        'Serves vegetarian dishes'
      ],
      rating: 4.2,
      category: 'Restaurant',
      cuisine: ['Italian'],
      priceRange: {'symbol': '\$\$', 'range': 'Moderate to expensive'},
    );

    return PoiDetailScreen(
      poi: weinsteinAndGavinos,
      onBack: () {
        //TODO: Implement back button functionality back to outdoor map screen for task 6.1.2
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Back button pressed')),
        );
      },
    );
  }
}