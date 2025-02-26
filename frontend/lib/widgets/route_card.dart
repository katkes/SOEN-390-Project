import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final String title;
  final String timeRange;
  final String duration;
  final String description;
  final List<IconData> icons;

  const RouteCard({
    super.key,
    required this.title,
    required this.timeRange,
    required this.duration,
    required this.description,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const SizedBox(width: 10),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: icons
                      .map((icon) => Padding(
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
    );
  }
}
