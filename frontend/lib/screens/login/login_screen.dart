/// This file defines the LoginScreen widget, which provides a user interface for
/// Google Sign-In authentication.
///
/// The LoginScreen displays a welcome message, a brief description, and a Google
/// Sign-In button. It also handles loading states and error messages.
library;

import 'package:flutter/material.dart';
import 'package:soen_390/widgets/google_sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final bool isLoading;
  final String? errorMessage;

  const LoginScreen({
    super.key,
    required this.onGoogleSignIn,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(5, 145, 35, 55),
      body: SafeArea(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(50, 145, 35, 55),
                    shape: BoxShape.circle),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Welcome to Your Calendar',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              const Text(
                'Sign in with Google to access your calendars and events',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Sign-in button or loading indicator
              if (isLoading)
                const CircularProgressIndicator()
              else
                GoogleSignInButton(
                  onPressed: onGoogleSignIn,
                ),
              if (errorMessage != null && errorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        )),
      ),
    );
  }
}
