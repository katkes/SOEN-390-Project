import 'package:flutter/material.dart';

class SetDestinationButton extends StatelessWidget {
  final String name;
  final double latitude;
  final double longitude;

  const SetDestinationButton({
    super.key,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.directions),
        label: const Text("Set Destination"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.pop(context, {
            'name': name,
            'lat': latitude,
            'lng': longitude,
          });
        },
      ),
    );
  }
}
