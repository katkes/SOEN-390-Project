import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/core/secure_storage.dart'; // Import your SecureStorage class
import 'secure_storage_test.mocks.dart';

/// Generates a mock class for `FlutterSecureStorage`.
@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorage secureStorage;

  /// Sets up the test environment before each test case.
  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorage(mockStorage);
  });

  /// Tests whether `storeToken` writes a token to secure storage.
  test('storeToken should write a token to secure storage', () async {
    const key = 'auth_token';
    const value = 'myTokenValue';

    await secureStorage.storeToken(key, value);

    // Verifies that the `write` method was called once with the correct arguments.
    verify(mockStorage.write(key: key, value: value)).called(1);
  });

  /// Tests whether `getToken` retrieves a stored token value.
  test('getToken should return stored token value', () async {
    const key = 'auth_token';
    const storedValue = 'myTokenValue';

    // Mocking the read method to return the storedValue.
    when(mockStorage.read(key: key)).thenAnswer((_) async => storedValue);

    final result = await secureStorage.getToken(key);

    expect(result, storedValue);

    // Verifies that the `read` method was called once with the correct key.
    verify(mockStorage.read(key: key)).called(1);
  });

  /// Tests whether `getToken` returns `null` if no token is stored.
  test('getToken should return null if token does not exist', () async {
    const key = 'auth_token';

    // Mocking the read method to return null.
    when(mockStorage.read(key: key)).thenAnswer((_) async => null);

    final result = await secureStorage.getToken(key);

    expect(result, isNull);

    // Verifies that the `read` method was called once.
    verify(mockStorage.read(key: key)).called(1);
  });

  /// Tests whether `deleteToken` removes a token from secure storage.
  test('deleteToken should remove a token from secure storage', () async {
    const key = 'auth_token';

    await secureStorage.deleteToken(key);

    // Verifies that the `delete` method was called once with the correct key.
    verify(mockStorage.delete(key: key)).called(1);
  });
}
