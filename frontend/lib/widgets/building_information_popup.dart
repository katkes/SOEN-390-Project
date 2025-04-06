import 'package:flutter/material.dart';
import 'package:soen_390/models/route_result.dart';
import 'package:soen_390/utils/waypoint_navigation_handler.dart';

class BuildingInformationPopup extends StatelessWidget {
  final String buildingName;
  final String buildingAddress;
  final String? photoUrl;
  final Function(RouteResult)? onRouteSelected;
  final WaypointNavigationHandler? navigationHandler;

  const BuildingInformationPopup({
    super.key,
    required this.buildingName,
    required this.buildingAddress,
    this.photoUrl,
    this.onRouteSelected,
    this.navigationHandler,
  });

  String abbreviateBuildingName(String name) {
    if (name.length > 27) {
      return "${name.split(" ")[0]} Bldg";
    } else {
      return name;
    }
  }

  Widget _buildImage() {
    const double imageWidth = 200;
    const double imageHeight = 100;
    const String fallbackAsset = "assets/images/buildings/hall.png";

    if (photoUrl != null) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        width: imageWidth,
        height: imageHeight,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: imageWidth,
            height: imageHeight,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
            width: imageWidth,
            height: imageHeight,
          );
        },
      );
    } else {
      return Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
        width: imageWidth,
        height: imageHeight,
      );
    }
  }

  Widget _buildBuildingInfo(BuildContext context, String name, String address) {
    final textTheme = Theme.of(context).textTheme;
    
    final textColor = Colors.black;

    return Column(
      children: [
        Text(
          name,
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,  
          ),
        ),
        const SizedBox(height: 5),
        Text(
          address,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12,
            // ignore: deprecated_member_use
            color: textColor.withOpacity(0.6), 
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleOpenWaypointSelection(BuildContext context) {
    (navigationHandler ??
            WaypointNavigationHandler(
              context: context,
              buildingName: buildingName,
              buildingAddress: buildingAddress,
              onRouteSelected: onRouteSelected,
            ))
        .openWaypointSelection();
  }

  @override
  Widget build(BuildContext context) {
    final abbreviatedName = abbreviateBuildingName(buildingName);
    final burgundyColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImage(),
              const SizedBox(height: 10),
              _buildBuildingInfo(context, abbreviatedName, buildingAddress),
            ],
          ),
          Positioned(
            bottom: -10,
            right: 2,
            child: ElevatedButton(
              onPressed: () => _handleOpenWaypointSelection(context),
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
