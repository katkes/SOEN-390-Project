import 'package:flutter/material.dart';
// import 'package:soen_390/styles/theme.dart';

class IndoorTrigger extends StatefulWidget {
  const IndoorTrigger({super.key});

  @override
  State<StatefulWidget> createState() => _IndoorTriggerState();
}

class _IndoorTriggerState extends State<IndoorTrigger> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76), // Alpha value = 0.3 * 255 ≈ 76
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: const Icon(
        Icons.location_on,
        size: 30,
        color: Colors.white,
      ),
    );
  }
}
