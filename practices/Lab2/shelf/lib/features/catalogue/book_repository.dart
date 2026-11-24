import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'book.dart';
import 'book_cache.dart';

typedef BooksResult = ({List<Book> items, bool fromCache});

abstract interface class BookRepository {
  Future<BooksResult> search(String query);
}

class HttpBookRepository implements BookRepository {
  HttpBookRepository(this._api, this._cache);

  final ApiClient _api;
  final BookCache _cache;

  @override
  Future<BooksResult> search(String query) async {
    try {
      final response = await _api.get(
        '/search.json',
        query: {'q': query, 'limit': '30'},
      );
      final data = _api.decode(response) as Map<String, dynamic>;
      final docs = data['docs'] as List<dynamic>;
      final books = docs
          .map((item) => Book.fromJson(item as Map<String, dynamic>))
          .toList();

      await _cache.save(books);

      return (items: books, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();

      if (saved == null) rethrow;

      return (items: saved, fromCache: true);
    } catch (error) {
      if (error is ApiException) rethrow;

      throw BadResponseException('books: $error');
    }
  }
}
