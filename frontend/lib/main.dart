import 'package:flutter/material.dart';
// import './widgets/campus_switch_button.dart';

// toggle test below

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   void _onBuildingSelectionChanged(String newSelection) {
//     // Nothing happening
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Test',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Testing building switch button'),
//         ),
//         body: Center(
//           child: CampusSwitch(
//             onSelectionChanged: _onBuildingSelectionChanged,
//             initialSelection: 'SGW',
//           ),
//         ),
//       ),
//     );
//   }

import 'package:soen_390/widgets/campus_switch_button.dart'; 
import 'package:soen_390/widgets/nav_bar.dart';
import 'package:soen_390/styles/theme.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String selectedBuilding = 'SGW'; // Track building selection

  void _onBuildingSelectionChanged(String newSelection) {
    setState(() {
      selectedBuilding = newSelection;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Building Switch Example'),
      ),
      body: Center(
        child: <Widget>[
          const Text('Home Page'),
          // Map Page with the CampusSwitch widget
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Map Page'),
            ],
          ),
          const Text('Profile Page'),
        ][_selectedIndex],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
