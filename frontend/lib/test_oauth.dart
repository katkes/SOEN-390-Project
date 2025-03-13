import 'package:flutter/widgets.dart'; // Required for WidgetsFlutterBinding.ensureInitialized()
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import '../services/auth_service.dart';
import '../core/secure_storage.dart';
import '../services/http_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- ADD THIS LINE
  await dotenv.load();
final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: dotenv.env['IOS_CLIENT_ID'],
    serverClientId: dotenv.env['WEB_CLIENT_ID'],
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
