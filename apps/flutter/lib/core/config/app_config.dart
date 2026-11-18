import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  static const _storage = FlutterSecureStorage();
  static const _serverUrlKey = 'server_base_url';

  static Future<String?> loadServerUrl() => _storage.read(key: _serverUrlKey);

  static Future<void> saveServerUrl(String url) async {
    final normalized = normalize(url);
    await _storage.write(key: _serverUrlKey, value: normalized);
  }

  static Future<void> clearServerUrl() => _storage.delete(key: _serverUrlKey);

  static String normalize(String url) {
    var v = url.trim();
    if (v.endsWith('/')) v = v.substring(0, v.length - 1);
    return v;
  }
}
