import 'package:flutter/material.dart';


class BuildingInformationPopup extends StatelessWidget {
  final String buildingName;
  final String buildingAddress;
  final String? photoUrl;
  final Function() onNavigateToWaypointPage; // Callback function to navigate

  const BuildingInformationPopup({
    super.key,
    required this.buildingName,
    required this.buildingAddress,
    this.photoUrl,
    required this.onNavigateToWaypointPage, // Accept the callback
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
              photoUrl != null
                  ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                width: 200,
                height: 100,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 200,
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/images/buildings/hall.png",
                    fit: BoxFit.cover,
                    width: 200,
                    height: 100,
                  );
                },
              )
                  : Image.asset(
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
              onPressed: onNavigateToWaypointPage, // Call the callback
              style: ElevatedButton.styleFrom(
                backgroundColor: burgundyColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: const Size(10, 10),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// builder: (context) => LocationTransportSelector(
// initialDestination: buildingAddress, // Autofill destination
// onConfirmRoute: (waypoints, mode) {
// // Handle confirmed route
// print("Confirmed waypoints: $waypoints, Mode: $mode");
// },
// ),
