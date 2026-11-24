import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'book.dart';
import 'book_repository.dart';

class CatalogueModel extends ChangeNotifier {
  CatalogueModel(this._repo);

  final BookRepository _repo;

  List<Book> items = const [];
  ApiException? error;
  bool loading = false;
  bool fromCache = false;
  String query = 'flutter';

  Future<void> search(String value) async {
    final next = value.trim().isEmpty ? 'flutter' : value.trim();

    query = next;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _repo.search(next);

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
}
