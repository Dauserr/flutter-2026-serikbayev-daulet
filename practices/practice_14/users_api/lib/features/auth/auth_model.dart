import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, {this.token});

  final SecureStore _store;
  String? token;

  bool get signedIn => token != null;

  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final value = 'tok_${email.hashCode}';

    await _store.saveToken(value);

    token = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();

    token = null;
    notifyListeners();
  }
}
