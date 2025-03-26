import 'package:flutter/material.dart';

/// Styling Constants for IndoorTrigger
const double kIndoorButtonIconSize = 30;
const double kIndoorButtonPadding = 10.0;
const double kIndoorButtonBorderRadius = 20.0;

const int kShadowAlpha = 76; // Equivalent to 0.3 opacity (0.3 * 255)
const double kShadowSpread = 2;
const double kShadowBlur = 5;
const Offset kShadowOffset = Offset(0, 4);

class IndoorTrigger extends StatefulWidget {
  const IndoorTrigger({super.key});

  @override
  State<StatefulWidget> createState() => _IndoorTriggerState();
}

class _IndoorTriggerState extends State<IndoorTrigger> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildIndoorButtonDecoration(context),
      padding: const EdgeInsets.all(kIndoorButtonPadding),
      child: const Icon(
        Icons.location_on,
        size: kIndoorButtonIconSize,
        color: Colors.white,
      ),
    );
  }

  BoxDecoration _buildIndoorButtonDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(kIndoorButtonBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(kShadowAlpha),
          spreadRadius: kShadowSpread,
          blurRadius: kShadowBlur,
          offset: kShadowOffset,
        ),
      ],
    );
  }
}
