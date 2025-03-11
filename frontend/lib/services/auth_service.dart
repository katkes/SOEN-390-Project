import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import '../core/secure_storage.dart';
import 'http_service.dart';

/// A service class that handles authentication operations using Google Sign-In.
///
/// This class manages Google authentication processes, including sign-in and sign-out
/// operations. It also handles the storage of authentication tokens using secure storage.
/// The class is configured to request read-only access to Google Calendar.
///
/// The class uses [GoogleSignIn] for authentication and [HttpService] for making
/// authenticated HTTP requests. It also integrates with [SecureStorage] for
/// persisting authentication tokens.
///
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// final authClient = await authService.signIn();
/// if (authClient != null) {
///   // Successfully signed in
/// }
/// ```
///
/// The class provides methods to:
/// * Sign in using Google authentication ([signIn])
/// * Sign out and clear stored tokens ([signOut])
/// * Clean up resources ([dispose])
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
  );
  final HttpService _httpService;

  AuthService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<auth.AuthClient?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final auth.AccessCredentials credentials = auth.AccessCredentials(
        auth.AccessToken(
            "Bearer", googleAuth.accessToken!, DateTime.now().toUtc()),
        null,
        ['https://www.googleapis.com/auth/calendar.readonly'],
      );

      final auth.AuthClient authClient = auth.authenticatedClient(
        _httpService.client, // Use HttpService's client
        credentials,
      );

      await SecureStorage.storeToken('access_token', googleAuth.accessToken!);

      return authClient;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await SecureStorage.deleteToken('access_token');
  }

  void dispose() {
    _httpService.dispose();
  }
}
