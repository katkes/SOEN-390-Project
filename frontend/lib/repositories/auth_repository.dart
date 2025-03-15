import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import '../services/auth_service.dart';
import '../core/secure_storage.dart';
import '../services/http_service.dart';

/// Repository class that handles authentication-related operations.
///
/// This class manages authentication state and provides methods for signing in and out.
/// It uses [AuthService] for authentication operations and [HttpService] for HTTP requests.
///
/// The repository can create authenticated HTTP clients for making requests to Google services,
/// particularly for Calendar API access.
///
/// Example:
/// ```dart
/// final authRepo = AuthRepository(authService);
/// final client = await authRepo.getAuthClient();
/// ```
class AuthRepository {
  final AuthService _authService;
  final HttpService _httpService;
  final SecureStorage _secureStorage;

  AuthRepository({
    required AuthService authService,
    required HttpService httpService,
    required SecureStorage secureStorage,
  })  : _authService = authService,
        _httpService = httpService,
        _secureStorage = secureStorage;

  Future<auth.AuthClient?> getAuthClient() async {
    final accessToken = await _secureStorage.getToken("access_token");

    if (accessToken != null) {
      final credentials = auth.AccessCredentials(
        auth.AccessToken("Bearer", accessToken, DateTime.now().toUtc()),
        null, // No refresh token
        ['https://www.googleapis.com/auth/calendar.readonly'],
      );

      return auth.authenticatedClient(_httpService.client, credentials);
    }

    return await _authService.signIn();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
