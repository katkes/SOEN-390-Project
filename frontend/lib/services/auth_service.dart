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
/// The class uses [GoogleSignIn] for authentication, [HttpService] for making
/// authenticated HTTP requests, and [SecureStorage] for persisting authentication tokens.
class AuthService {
  final GoogleSignIn _googleSignIn;
  final HttpService _httpService;
  final SecureStorage _secureStorage;
  final AuthClientFactory _authClientFactory;

  AuthService({
    required GoogleSignIn googleSignIn,
    required HttpService httpService,
    required SecureStorage secureStorage,
    required AuthClientFactory authClientFactory,
  })  : _googleSignIn = googleSignIn,
        _httpService = httpService,
        _secureStorage = secureStorage,
        _authClientFactory = authClientFactory;

Future<auth.AuthClient?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Sign-in canceled by user");
        return null;
      }

      print("User Signed In: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Access Token: ${googleAuth.accessToken}");
      print("ID Token: ${googleAuth.idToken}");

      final auth.AccessCredentials credentials = auth.AccessCredentials(
        auth.AccessToken(
            "Bearer", googleAuth.accessToken!, DateTime.now().toUtc()),
        null,
        ['https://www.googleapis.com/auth/calendar.readonly'],
      );

      final auth.AuthClient authClient = _authClientFactory.createAuthClient(
        _httpService,
        credentials,
      );

      await _secureStorage.storeToken('access_token', googleAuth.accessToken!);
      print("Token stored successfully");

      return authClient;
    } catch (e) {
      print("Sign-in error: $e");
      return null;
    }
}

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _secureStorage.deleteToken('access_token');
  }

  void dispose() {
    _httpService.dispose();
  }
}

/// A factory class for creating authenticated clients using HttpService.
class AuthClientFactory {
  auth.AuthClient createAuthClient(
      HttpService baseClient, auth.AccessCredentials credentials) {
    return auth.authenticatedClient(baseClient.client, credentials);
  }
}
