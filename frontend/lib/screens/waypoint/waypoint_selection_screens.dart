import 'package:flutter/material.dart';
import '../../widgets/location_transport_selector.dart';
import '../../widgets/route_card.dart';
import '../../widgets/nav_bar.dart';

class WaypointSelectionScreen extends StatefulWidget {
  const WaypointSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WaypointSelectionScreenState createState() =>
      _WaypointSelectionScreenState();
}

class _WaypointSelectionScreenState extends State<WaypointSelectionScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index != 1) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff912338),
        title: Text("Find my Way",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [Icon(Icons.more_vert, color: Colors.white)],
      ),
      body: Column(
        children: [
          LocationTransportSelector(),
          Expanded(
            child: ListView(
              children: [
                RouteCard(
                  title: "Concordia Shuttle",
                  timeRange: "10:00 - 10:30",
                  duration: "30 min",
                  description: "10:00 from Sherbrooke",
                  icons: [Icons.accessible, Icons.train],
                ),
                RouteCard(
                  title: "Exo 11",
                  timeRange: "9:52 - 10:25",
                  duration: "32 min",
                  description: "Walk 5 minutes to Montreal-West",
                  icons: [Icons.directions_walk, Icons.train],
                ),
                RouteCard(
                  title: "432",
                  timeRange: "10:12 - 10:58",
                  duration: "46 min",
                  description: "Walk 3 minutes",
                  icons: [Icons.directions_walk, Icons.train],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
