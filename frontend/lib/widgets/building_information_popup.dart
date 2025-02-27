import 'package:flutter/material.dart';

/// A widget that displays building information in a popup format.
///
/// This widget creates a popup display containing building information including:
/// * Building name (automatically abbreviated if too long)
/// * Building address
/// * Building photo (optional)
///
/// The popup uses the app's primary color scheme and provides a consistent
/// layout for building information across the application.
///
/// Example usage:
/// ```dart
/// BuildingInformationPopup(
///   buildingName: 'Henry F. Hall Building',
///   buildingAddress: '1455 De Maisonneuve Blvd. W.',
///   photoUrl: 'https://example.com/hall-building.jpg',
/// )
/// ```

class BuildingInformationPopup extends StatelessWidget {
  final String buildingName;
  final String buildingAddress;
  final String? photoUrl;

  const BuildingInformationPopup({
    super.key,
    required this.buildingName,
    required this.buildingAddress,
    this.photoUrl,
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                print("Button clicked");
              },
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
