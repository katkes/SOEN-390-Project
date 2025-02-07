import 'package:flutter/material.dart';
// import 'package:soen_390/styles/theme.dart'; 

class IndoorTrigger extends StatefulWidget {
  const IndoorTrigger({super.key});

  @override
  State<StatefulWidget> createState() => _IndoorTrigger();
}

class _IndoorTrigger extends State<IndoorTrigger> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), 
            spreadRadius: 2, 
            blurRadius: 5, 
            offset: Offset(0, 4), 
          ),
        ], 
      ),
      padding: EdgeInsets.all(10), 
      child: Icon(
        Icons.location_on,
        size: 30,
        color: Colors.white, 
      ),
    );
  }
}
