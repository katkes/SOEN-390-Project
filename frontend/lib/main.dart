import 'package:flutter/material.dart';
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/widgets/search_bar.dart';
import 'package:soen_390/styles/theme.dart';
import 'package:soen_390/widgets/outdoor_map.dart';
import 'package:soen_390/widgets/campus_switch_button.dart';
import 'package:soen_390/widgets/indoor_navigation_button.dart';
import 'package:latlong2/latlong.dart';

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
          Stack(
            children: [
              Positioned.fill(
                child: MapRectangle(location: _currentLocation),
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
            ],
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
//
// import 'package:flutter/material.dart';
// import 'package:soen_390/widgets/nav_bar.dart';
// import 'package:soen_390/widgets/search_bar.dart';
// import 'package:soen_390/styles/theme.dart';
// import 'package:soen_390/widgets/outdoor_map.dart';
// import 'package:soen_390/widgets/campus_switch_button.dart';
// import 'package:soen_390/widgets/indoor_navigation_button.dart';
// import 'package:soen_390/widgets/building_details.dart'; // Added this import
// import 'package:latlong2/latlong.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: appTheme,
//       home: const MyHomePage(title: 'Campus Map'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   TextEditingController searchController = TextEditingController();
//   int _selectedIndex = 0;
//   LatLng _currentLocation = LatLng(45.497856, -73.579588);
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   void _updateCampusLocation(LatLng newLocation) {
//     setState(() {
//       _currentLocation = newLocation;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.menu, color: Colors.white, size: 30),
//           onPressed: () {},
//         ),
//         backgroundColor: Theme.of(context).primaryColor,
//         title: Text(
//           widget.title,
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.more_vert, color: Colors.white, size: 30),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: [
//           const Center(child: Text('Home Page')),
//           Stack(
//             children: [
//               Positioned.fill(
//                 child: BuildingBoundariesMap(), // Added this widget
//               ),
//               Positioned(
//                 top: 10,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: CampusSwitch(
//                     onSelectionChanged: (selectedCampus) {},
//                     onLocationChanged: _updateCampusLocation,
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: -80,
//                 left: 0,
//                 child: SearchBarWidget(controller: searchController),
//               ),
//               Positioned(
//                 bottom: 10,
//                 right: 21,
//                 child: IndoorTrigger(),
//               ),
//             ],
//           ),
//           const Center(child: Text('Profile Page')),
//         ],
//       ),
//       bottomNavigationBar: NavBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
// }

