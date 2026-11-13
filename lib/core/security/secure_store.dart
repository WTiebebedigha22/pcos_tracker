import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper for any sensitive value (tokens, PHI cached locally).
/// Do NOT use SharedPreferences for these.
class SecureStore {
  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static Future<void> write(String k, String v) => _s.write(key: k, value: v);
  static Future<String?> read(String k) => _s.read(key: k);
  static Future<void> delete(String k) => _s.delete(key: k);
  static Future<void> clear() => _s.deleteAll();
}
