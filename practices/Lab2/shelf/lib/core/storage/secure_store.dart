import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  const SecureStore({this.storage = const FlutterSecureStorage()});

  final FlutterSecureStorage storage;

  Future<void> saveToken(String token) {
    return storage.write(key: 'token', value: token);
  }

  Future<String?> readToken() {
    return storage.read(key: 'token');
  }

  Future<void> clear() {
    return storage.delete(key: 'token');
  }
}
