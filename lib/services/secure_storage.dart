import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();


  static Future<void> saveToken(String token) async {
    await _storage.write(key: "hf_token", value: token);
  }


  static Future<String?> getToken() async {
    return await _storage.read(key: "hf_token");
  }


  static Future<void> deleteToken() async {
    await _storage.delete(key: "hf_token");
  }
}
