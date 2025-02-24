import 'package:flutter/material.dart';
import 'package:soen_390/screens/waypoint/waypoint_selection_screens.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/search_bar.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:soen_390/widgets/campus_switch_button.dart';
import 'package:soen_390/widgets/indoor_navigation_button.dart';
import 'package:latlong2/latlong.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: const MyHomePage(title: 'Campus Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;
  LatLng _currentLocation = LatLng(45.497856, -73.579588);
  http.Client? _httpClient;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client(); // Initialize the client
  }

  @override
  void dispose() {
    _httpClient?.close(); // Close the client
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateCampusLocation(LatLng newLocation) {
    setState(() {
      _currentLocation = newLocation;
    });
  }

  void _openWaypointSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WaypointSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () {},
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Center(child: Text('Home Page')),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: [
                  Positioned(
                    bottom: 5,
                    left: 10,
                    right: 10,
                    child: Center(
                      child: SizedBox(
                        width: 460,
                        height: 570,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: MapWidget(
                            location: _currentLocation,
                            httpClient: _httpClient!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CampusSwitch(
                        onSelectionChanged: (selectedCampus) {},
                        onLocationChanged: _updateCampusLocation,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: 0,
                    child: SearchBarWidget(controller: searchController),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 21,
                    child: IndoorTrigger(),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 21,
                    child: ElevatedButton(
                      onPressed: _openWaypointSelection,
                      child: Text("Find My Way"),
                    ),
                  ),
                ],
              );
            },
          ),
          const Center(child: Text('Profile Page')),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
