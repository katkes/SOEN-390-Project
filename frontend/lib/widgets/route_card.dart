// RouteCard is a reusable widget that displays route details in a structured card format.
// It includes the route title, time range, duration, description, and relevant transport icons.
// This widget is used in WaypointSelectionScreen to show confirmed routes dynamically.
// The card is styled with rounded corners, padding, and a shadow for a clean UI appearance.

import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final String duration;
  final String description;
  final bool isCrossCampus;
  final List<IconData> icons;
  final dynamic routeData;
  final VoidCallback onCardTapped;

  const RouteCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.duration,
    required this.description,
    required this.isCrossCampus,
    required this.icons,
    required this.routeData,
    required this.onCardTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTapped,
      child: Container(
        width: 382,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(duration,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(timeRange,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(description,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCrossCampus)
                  const Text("Cross-campus route",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:  
                    icons.map((icon) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(icon, size: 20),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
