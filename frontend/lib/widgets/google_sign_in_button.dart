import 'package:flutter/material.dart';

/// Google Sign-In Button Styling Constants
const double kGoogleButtonHeight = 50;
const double kGoogleIconSize = 36;
const double kGoogleButtonPadding = 12.0;
const double kGoogleButtonBorderRadius = 8.0;

const Color kGoogleButtonBackground = Colors.white;
const Color kGoogleButtonForeground = Colors.black87;
final Color kGoogleButtonBorderColor = Colors.grey.shade300;

/// A reusable Google Sign-In button with consistent styling and semantics.
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sign in with Google',
      child: ElevatedButton(
        onPressed: onPressed,
        style: _googleButtonStyle(),
        child: _buildGoogleButtonContent(),
      ),
    );
  }

  /// Helper method to style the button consistently.
  ButtonStyle _googleButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: kGoogleButtonBackground,
      foregroundColor: kGoogleButtonForeground,
      minimumSize: const Size(double.infinity, kGoogleButtonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kGoogleButtonBorderRadius),
        side: BorderSide(color: kGoogleButtonBorderColor),
      ),
      elevation: 1,
    );
  }

  /// Extracted helper method for the logo + label layout.
  Widget _buildGoogleButtonContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kGoogleButtonPadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/Google_G_logo.png',
            height: kGoogleIconSize,
            width: kGoogleIconSize,
          ),
          const SizedBox(width: 16),
          const Text(
            'Sign in with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
