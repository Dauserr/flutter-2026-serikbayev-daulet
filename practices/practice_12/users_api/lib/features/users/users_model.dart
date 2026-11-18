import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool fromCache = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _repo.getAll();

      items = result.items;
      fromCache = result.fromCache;
    } on ApiException catch (error) {
      fromCache = false;
      this.error = error;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<ApiException?> create(User draft) async {
    try {
      final created = await _repo.create(draft);

      items = [created, ...items];
      error = null;
      notifyListeners();

      return null;
    } on ApiException catch (error) {
      return error;
    }
  }
}
