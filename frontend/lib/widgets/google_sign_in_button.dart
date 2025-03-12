/// This file defines a custom Google Sign-In button widget for Flutter applications.
/// It uses the `flutter_svg` package to display the Google "G" logo and provides
/// a clean, visually appealing button with accessibility features.
///
/// The button is designed to be easily integrated into authentication flows,
/// triggering a provided `onPressed` callback when tapped.
library;

import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({Key? key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Sign in with Google',
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 1,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SvgPicture.asset(
              //   'frontend/assets/svg/Google__G__logo.svg',
              //   height: 24,
              //   width: 24,
              //   placeholderBuilder: (context) => SvgPicture.network(
              //     'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
              //     height: 24,
              //     width: 24,
              //   ),
              // ),
              SizedBox(width: 16),
              Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
