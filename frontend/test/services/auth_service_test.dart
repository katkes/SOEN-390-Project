import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/services/http_service.dart';
import 'package:soen_390/core/secure_storage.dart';

@GenerateMocks([
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  HttpService
])
void main() {
  late AuthService authService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockHttpService mockHttpService;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockHttpService = MockHttpService();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    authService = AuthService(httpService: mockHttpService);
  });

  group('AuthService', () {
    test('signIn - successful', () async {
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication)
          .thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(mockGoogleSignInAuthentication.accessToken)
          .thenReturn('test_access_token');
      when(mockHttpService.client).thenReturn(http.Client());

      final result = await authService.signIn();

      expect(result, isNotNull);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockGoogleSignInAccount.authentication).called(1);
    });

    test('signIn - user cancels', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await authService.signIn();

      expect(result, isNull);
      verify(mockGoogleSignIn.signIn()).called(1);
    });

    test('signOut', () async {
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      await authService.signOut();

      verify(mockGoogleSignIn.signOut()).called(1);
    });

    test('dispose', () {
      authService.dispose();
      verify(mockHttpService.dispose()).called(1);
    });
  });
}
