import 'package:flutter/material.dart';

class IndoorTrigger extends StatefulWidget {
  IndoorTrigger({super.key});

  @override
  State<StatefulWidget> createState() => _IndoorTrigger();
}

class _IndoorTrigger extends State<IndoorTrigger> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Icon(
        Icons.location_on, 
        size: 45, 
        color: Colors.red, 
      ),
    );
  }
}
