import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'shelf_entry.dart';
import 'shelf_repository.dart';

class ShelfModel extends ChangeNotifier {
  ShelfModel(this._repo);

  final ShelfRepository _repo;

  List<ShelfEntry> items = const [];
  ApiException? error;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      items = await _repo.getAll();
    } on ApiException catch (error) {
      this.error = error;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<ApiException?> save(ShelfEntry entry) async {
    try {
      if (entry.id == null) {
        await _repo.create(entry);
      } else {
        await _repo.update(entry);
      }

      await load();
      return null;
    } on ApiException catch (error) {
      return error;
    }
  }

  Future<ApiException?> delete(String id) async {
    try {
      await _repo.delete(id);
      await load();
      return null;
    } on ApiException catch (error) {
      return error;
    }
  }
}
