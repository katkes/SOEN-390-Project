import 'package:flutter/material.dart';

class BuildingInformationPopup extends StatelessWidget {
  final String buildingName;
  final String buildingAddress;

  const BuildingInformationPopup({
    super.key,
    required this.buildingName,
    required this.buildingAddress,
  });

  String _getAbbreviatedName(String name) {
  
    if (name.length > 27) {
      return "${name.split(" ")[0]} Bldg"; 
    } else {
      return name;  
    }
  }

  @override
  Widget build(BuildContext context) {
    String abbreviatedName = _getAbbreviatedName(buildingName); 

    Color burgundyColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
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
                abbreviatedName,
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
          Positioned(
            bottom: -10,
            right: 2,
            child: ElevatedButton(
              onPressed: () {
                // Button action here
                print("Button clicked");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: burgundyColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), 
                minimumSize: Size(10, 10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                 
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward, 
                    color: Colors.white,
                    size:15, 
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


