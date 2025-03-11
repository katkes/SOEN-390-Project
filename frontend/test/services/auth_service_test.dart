import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:soen_390/services/auth_service.dart'; // Update with the actual package path
import 'package:soen_390/core/secure_storage.dart';
import 'package:soen_390/services/http_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
  MockSpec<HttpService>(),
  MockSpec<SecureStorage>(),
  MockSpec<AuthClientFactory>(),
  MockSpec<auth.AuthClient>(),
])
void main() {
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuth;
  late MockHttpService mockHttpService;
  late MockSecureStorage mockSecureStorage;
  late MockAuthClientFactory mockAuthClientFactory;
  late MockAuthClient mockAuthClient;
  late AuthService authService;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuth = MockGoogleSignInAuthentication();
    mockHttpService = MockHttpService();
    mockSecureStorage = MockSecureStorage();
    mockAuthClientFactory = MockAuthClientFactory();
    mockAuthClient = MockAuthClient();

    authService = AuthService(
      googleSignIn: mockGoogleSignIn,
      httpService: mockHttpService,
      secureStorage: mockSecureStorage,
      authClientFactory: mockAuthClientFactory,
    );
  });

  group('AuthService', () {
    test('should sign in successfully and store access token', () async {
      // Mock Google Sign-In process
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication)
          .thenAnswer((_) async => mockGoogleSignInAuth);
      when(mockGoogleSignInAuth.accessToken).thenReturn("mock_access_token");

      // Mock auth client creation
      when(mockAuthClientFactory.createAuthClient(any, any))
          .thenReturn(mockAuthClient);
      when(mockSecureStorage.storeToken('access_token', 'mock_access_token'))
          .thenAnswer((_) async => Future.value());

      final result = await authService.signIn();

      expect(result, isNotNull);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockSecureStorage.storeToken('access_token', 'mock_access_token'))
          .called(1);
    });

    test('should return null when sign-in is cancelled', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await authService.signIn();

      expect(result, isNull);
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockSecureStorage.storeToken(any, any));
    });

    test('should return null when sign-in throws an exception', () async {
      when(mockGoogleSignIn.signIn()).thenThrow(Exception('Sign-in error'));

      final result = await authService.signIn();

      expect(result, isNull);
      verify(mockGoogleSignIn.signIn()).called(1);
    });

    test('should sign out and delete access token', () async {
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());
      when(mockSecureStorage.deleteToken('access_token'))
          .thenAnswer((_) async => Future.value());

      await authService.signOut();

      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockSecureStorage.deleteToken('access_token')).called(1);
    });

    test('should dispose HttpService', () {
      authService.dispose();

      verify(mockHttpService.dispose()).called(1);
    });
  });
}
