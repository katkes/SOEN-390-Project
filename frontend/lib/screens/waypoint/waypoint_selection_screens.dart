import 'package:flutter/material.dart';
import '../../widgets/location_transport_selector.dart';
import '../../widgets/nav_bar.dart';
import '../../widgets/route_card.dart';

class WaypointSelectionScreen extends StatefulWidget {
  const WaypointSelectionScreen({super.key});

  @override
  WaypointSelectionScreenState createState() => WaypointSelectionScreenState();
}

class WaypointSelectionScreenState extends State<WaypointSelectionScreen> {
  final int _selectedIndex = 1;
  List<Map<String, dynamic>> confirmedRoutes = [];

  void _handleRouteConfirmation(List<String> waypoints, String transportMode) {
    setState(() {
      confirmedRoutes.add({
        "title": "Custom Route ${confirmedRoutes.length + 1}",
        "timeRange": "10:00 - 10:30", // Placeholder time
        "duration": "${waypoints.length * 10} min", // Example logic
        "description": waypoints.join(" → "), // Show waypoints in a string
        "icons": _getIconsForTransport(transportMode),
      });
    });

    print("Final confirmed route: $waypoints, Mode: $transportMode");
  }

  List<IconData> _getIconsForTransport(String mode) {
    switch (mode) {
      case "Car":
        return [Icons.directions_car];
      case "Bike":
        return [Icons.directions_bike];
      case "Train or Bus":
        return [Icons.train];
      case "Walk":
        return [Icons.directions_walk];
      default:
        return [Icons.help_outline];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff912338),
        title: const Text("Find my Way",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [Icon(Icons.more_vert, color: Colors.white)],
      ),
      body: Column(
        children: [
          LocationTransportSelector(onConfirmRoute: _handleRouteConfirmation),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: confirmedRoutes.length,
              itemBuilder: (context, index) {
                final route = confirmedRoutes[index];
                return RouteCard(
                  title: route["title"],
                  timeRange: route["timeRange"],
                  duration: route["duration"],
                  description: route["description"],
                  icons: route["icons"],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          if (index != 1) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
