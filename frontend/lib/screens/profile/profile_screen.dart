import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final VoidCallback onSignOut;
  final VoidCallback onViewCalendar;
  final bool isLoading;
  final String? errorMessage;

  const UserProfileScreen({
    super.key,
    this.displayName,
    this.email,
    this.photoUrl,
    required this.onSignOut,
    required this.onViewCalendar,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: onSignOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile image
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl!) : null,
                      backgroundColor: const Color.fromARGB(50, 145, 35, 55),
                      child: photoUrl == null
                          ? Text(
                              displayName?.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(
                                  fontSize: 40,
                                  color: Theme.of(context).primaryColor),
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // User name
                    Text(
                      displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User email
                    Text(
                      email ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // View calendar button
                    ElevatedButton.icon(
                      onPressed: onViewCalendar,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('View My Calendar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Error message if any
                    if (errorMessage != null && errorMessage!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
