import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:soen_390/repositories/auth_repository.dart'; // Update with the actual package path
import 'package:soen_390/services/auth_service.dart';
import 'package:soen_390/core/secure_storage.dart';
import 'package:soen_390/services/http_service.dart';

import 'auth_repository_test.mocks.dart';

/// Generates mock classes for `AuthService`, `HttpService`, `SecureStorage`, and `AuthClient`.
@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<HttpService>(),
  MockSpec<SecureStorage>(),
  MockSpec<auth.AuthClient>(),
])

/// Main function for testing the `AuthRepository` class.
void main() {
  late MockAuthService mockAuthService;
  late MockHttpService mockHttpService;
  late MockSecureStorage mockSecureStorage;
  late MockAuthClient mockAuthClient;
  late AuthRepository authRepository;

  /// Sets up the test environment before each test case.
  setUp(() {
    mockAuthService = MockAuthService();
    mockHttpService = MockHttpService();
    mockSecureStorage = MockSecureStorage();
    mockAuthClient = MockAuthClient();

    // Initializes the `AuthRepository` with mocked dependencies.
    authRepository = AuthRepository(
      authService: mockAuthService,
      httpService: mockHttpService,
      secureStorage: mockSecureStorage,
    );
  });

  /// Group of tests for the `getAuthClient` method.
  group('AuthRepository - getAuthClient', () {
    /// Tests if `getAuthClient` returns an authenticated client when a valid token exists.
    test('should return an authenticated client when a valid token exists',
        () async {
      // Mock stored token retrieval.
      when(mockSecureStorage.getToken("access_token"))
          .thenAnswer((_) async => "mock_access_token");
      when(mockHttpService.client).thenReturn(http.Client());

      final result = await authRepository.getAuthClient();

      expect(result, isNotNull);
      verify(mockSecureStorage.getToken("access_token")).called(1);
      verify(mockHttpService.client).called(1);
    });

    /// Tests if `getAuthClient` returns a new authenticated client when no token is found and sign-in succeeds.
    test(
        'should return a new authenticated client when no token is found and sign-in succeeds',
        () async {
      // Mock token absence and successful sign-in.
      when(mockSecureStorage.getToken("access_token"))
          .thenAnswer((_) async => null);
      when(mockAuthService.signIn()).thenAnswer((_) async => mockAuthClient);

      final result = await authRepository.getAuthClient();

      expect(result, equals(mockAuthClient));
      verify(mockSecureStorage.getToken("access_token")).called(1);
      verify(mockAuthService.signIn()).called(1);
    });

    /// Tests if `getAuthClient` returns `null` when no token is found and sign-in fails.
    test('should return null when no token is found and sign-in fails',
        () async {
      // Mock token absence and failed sign-in.
      when(mockSecureStorage.getToken("access_token"))
          .thenAnswer((_) async => null);
      when(mockAuthService.signIn()).thenAnswer((_) async => null);

      final result = await authRepository.getAuthClient();

      expect(result, isNull);
      verify(mockSecureStorage.getToken("access_token")).called(1);
      verify(mockAuthService.signIn()).called(1);
    });
  });

  /// Group of tests for the `signOut` method.
  group('AuthRepository - signOut', () {
    /// Tests if `signOut` successfully calls the `signOut` method in `AuthService`.
    test('should call signOut on AuthService', () async {
      when(mockAuthService.signOut()).thenAnswer((_) async => Future.value());

      await authRepository.signOut();

      verify(mockAuthService.signOut()).called(1);
    });
  });
}
