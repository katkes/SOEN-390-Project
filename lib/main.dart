import 'package:flutter/material.dart';
import 'widgets/Campus_switch_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
<<<<<<< HEAD
  const MyApp({super.key});
=======
>>>>>>> 873e4dc (Formatted dart files)
  void _onBuildingSelectionChanged(String newSelection) {
    // Nothing happening
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Testing building switch button'),
        ),
        body: Center(
          child: BuildingSwitch(
            onSelectionChanged: _onBuildingSelectionChanged,
            initialSelection: 'SGW',
          ),
        ),
      ),
    );
  }
}
