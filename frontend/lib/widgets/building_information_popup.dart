import 'package:flutter/material.dart';

class BuildingInformationPopup extends StatelessWidget {
  final String buildingName;
  final String buildingAddress;

  const BuildingInformationPopup({
    super.key,
    required this.buildingName,
    required this.buildingAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/buildings/hall.png",
            fit: BoxFit.cover,
            width: 200,
            height: 100,
          ),
          const SizedBox(height: 10),
          Text(
            buildingName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            buildingAddress,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
