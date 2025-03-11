import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A utility class for securely storing and managing tokens using Flutter's secure storage.
///
/// This class provides static methods to handle token operations:
/// * Storing tokens securely
/// * Retrieving stored tokens
/// * Deleting tokens
///
/// Example usage:
/// ```dart
/// await SecureStorage.storeToken('auth_token', 'myTokenValue');
/// String? token = await SecureStorage.getToken('auth_token');
/// await SecureStorage.deleteToken('auth_token');
/// ```
///
/// The class uses [FlutterSecureStorage] internally to ensure secure storage
/// of sensitive data like authentication tokens.

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static Future<void> storeToken(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getToken(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }
}
