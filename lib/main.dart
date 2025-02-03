import 'package:flutter/material.dart';
import 'widgets/building_switch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void _onBuildingSelectionChanged(String newSelection) {
    print('Building selected: $newSelection');
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
