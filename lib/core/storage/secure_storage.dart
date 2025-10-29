import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _accessKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _accessKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _accessKey);
  }

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  static Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  static Future<void> deleteRefreshToken() => _storage.delete(key: _refreshKey);

  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  static Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  static Future<void> deleteUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
