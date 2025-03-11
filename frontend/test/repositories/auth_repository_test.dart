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

@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<HttpService>(),
  MockSpec<SecureStorage>(),
  MockSpec<auth.AuthClient>(),
])
void main() {
  late MockAuthService mockAuthService;
  late MockHttpService mockHttpService;
  late MockSecureStorage mockSecureStorage;
  late MockAuthClient mockAuthClient;
  late AuthRepository authRepository;

  setUp(() {
    mockAuthService = MockAuthService();
    mockHttpService = MockHttpService();
    mockSecureStorage = MockSecureStorage();
    mockAuthClient = MockAuthClient();

    authRepository = AuthRepository(
      authService: mockAuthService,
      httpService: mockHttpService,
      secureStorage: mockSecureStorage,
    );
  });

  group('AuthRepository - getAuthClient', () {
    test('should return an authenticated client when a valid token exists',
        () async {
      when(mockSecureStorage.getToken("access_token"))
          .thenAnswer((_) async => "mock_access_token");
      when(mockHttpService.client).thenReturn(http.Client());

      // final credentials = auth.AccessCredentials(
      //   auth.AccessToken("Bearer", "mock_access_token", DateTime.now().toUtc()),
      //   null,
      //   ['https://www.googleapis.com/auth/calendar.readonly'],
      // );

      final result = await authRepository.getAuthClient();

      expect(result, isNotNull);
      verify(mockSecureStorage.getToken("access_token")).called(1);
      verify(mockHttpService.client).called(1);
    });

    test(
        'should return a new authenticated client when no token is found and sign-in succeeds',
        () async {
      when(mockSecureStorage.getToken("access_token"))
          .thenAnswer((_) async => null);
      when(mockAuthService.signIn()).thenAnswer((_) async => mockAuthClient);

      final result = await authRepository.getAuthClient();

      expect(result, equals(mockAuthClient));
      verify(mockSecureStorage.getToken("access_token")).called(1);
      verify(mockAuthService.signIn()).called(1);
    });

    test('should return null when no token is found and sign-in fails',
        () async {
      when(mockSecureStorage.getToken("access_token"))
          .thenAnswer((_) async => null);
      when(mockAuthService.signIn()).thenAnswer((_) async => null);

      final result = await authRepository.getAuthClient();

      expect(result, isNull);
      verify(mockSecureStorage.getToken("access_token")).called(1);
      verify(mockAuthService.signIn()).called(1);
    });
  });

  group('AuthRepository - signOut', () {
    test('should call signOut on AuthService', () async {
      when(mockAuthService.signOut()).thenAnswer((_) async => Future.value());

      await authRepository.signOut();

      verify(mockAuthService.signOut()).called(1);
    });
  });
}
