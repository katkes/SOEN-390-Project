import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:soen_390/core/secure_storage.dart'; // Import your SecureStorage class
import 'secure_storage_test.mocks.dart';

// Generate a mock class
@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorage secureStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorage(mockStorage);
  });

  test('storeToken should write a token to secure storage', () async {
    const key = 'auth_token';
    const value = 'myTokenValue';

    await secureStorage.storeToken(key, value);

    verify(mockStorage.write(key: key, value: value)).called(1);
  });

  test('getToken should return stored token value', () async {
    const key = 'auth_token';
    const storedValue = 'myTokenValue';

    when(mockStorage.read(key: key)).thenAnswer((_) async => storedValue);

    final result = await secureStorage.getToken(key);

    expect(result, storedValue);
    verify(mockStorage.read(key: key)).called(1);
  });

  test('getToken should return null if token does not exist', () async {
    const key = 'auth_token';

    when(mockStorage.read(key: key)).thenAnswer((_) async => null);

    final result = await secureStorage.getToken(key);

    expect(result, isNull);
    verify(mockStorage.read(key: key)).called(1);
  });

  test('deleteToken should remove a token from secure storage', () async {
    const key = 'auth_token';

    await secureStorage.deleteToken(key);

    verify(mockStorage.delete(key: key)).called(1);
  });
}
