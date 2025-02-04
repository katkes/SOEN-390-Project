import 'package:flutter/material.dart';
import './widgets/canpus_switch_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
