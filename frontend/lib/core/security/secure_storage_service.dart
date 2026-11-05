import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = {};

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String keyAccessToken = 'kiosk_access_token';
  static const String keyUserRole = 'kiosk_user_role';
  static const String keyUsername = 'kiosk_username';
  static const String keyTableNumber = 'kiosk_table_number';
  static const String keySelectedLanguage = 'kiosk_selected_language';

  Future<void> write(String key, String value) async {
    _memoryFallback[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Secure storage unavailable on some web/desktop sandboxes; memory fallback active
    }
  }

  Future<String?> read(String key) async {
    try {
      final val = await _storage.read(key: key);
      if (val != null) return val;
    } catch (_) {}
    return _memoryFallback[key];
  }

  Future<void> delete(String key) async {
    _memoryFallback.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    _memoryFallback.clear();
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }

  // Convenience Methods
  Future<void> saveAuthToken(String token, String role, String username) async {
    await write(keyAccessToken, token);
    await write(keyUserRole, role);
    await write(keyUsername, username);
  }

  Future<String?> getAuthToken() => read(keyAccessToken);
  Future<String?> getUserRole() => read(keyUserRole);
  Future<String?> getUsername() => read(keyUsername);

  Future<void> clearAuthToken() async {
    await delete(keyAccessToken);
    await delete(keyUserRole);
    await delete(keyUsername);
  }
}

