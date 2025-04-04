import 'package:flutter/material.dart';

/// Styling Constants for IndoorNavigationButton
const double kIndoorButtonIconSize = 30;
const double kIndoorButtonPadding = 10.0;
const double kIndoorButtonBorderRadius = 20.0;

const int kShadowAlpha = 76; // Equivalent to 0.3 opacity (0.3 * 255)
const double kShadowSpread = 2;
const double kShadowBlur = 5;
const Offset kShadowOffset = Offset(0, 4);

/// Shared shadow style for the button
final BoxShadow kIndoorButtonShadow = BoxShadow(
  color: Colors.black.withAlpha(kShadowAlpha),
  spreadRadius: kShadowSpread,
  blurRadius: kShadowBlur,
  offset: kShadowOffset,
);

class IndoorNavigationButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const IndoorNavigationButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: _buildIndoorButtonDecoration(context),
        padding: const EdgeInsets.all(kIndoorButtonPadding),
        child: const Icon(
          Icons.location_on,
          size: kIndoorButtonIconSize,
          color: Colors.white,
        ),
      ),
    );
  }

  BoxDecoration _buildIndoorButtonDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(kIndoorButtonBorderRadius),
      boxShadow: [kIndoorButtonShadow],
    );
  }
}
