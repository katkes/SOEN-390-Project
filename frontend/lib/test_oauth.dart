import 'package:flutter/widgets.dart'; // Required for WidgetsFlutterBinding.ensureInitialized()
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import '../services/auth_service.dart';
import '../core/secure_storage.dart';
import '../services/http_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- ADD THIS LINE

final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId:
        "521610144578-4nhqk5c28m7jsmjefao9g742s7dh5bug.apps.googleusercontent.com", // iOS-specific Client ID
    serverClientId:
        "521610144578-qblu7gm9h319mm44vgk3ihluvg4tegd9.apps.googleusercontent.com", // Optional for backend
    scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
  );


  final HttpService httpService = HttpService();
  final SecureStorage secureStorage =
      SecureStorage(const FlutterSecureStorage());
  final AuthClientFactory authClientFactory = AuthClientFactory();

  final AuthService authService = AuthService(
    googleSignIn: googleSignIn,
    httpService: httpService,
    secureStorage: secureStorage,
    authClientFactory: authClientFactory,
  );

  print("Attempting to sign in...");

  final auth.AuthClient? authClient = await authService.signIn();

  if (authClient != null) {
    print("OAuth authentication successful!");
  } else {
    print("OAuth authentication failed.");
  }

  print("Signing out...");
  await authService.signOut();
  print("Signed out successfully.");
}
