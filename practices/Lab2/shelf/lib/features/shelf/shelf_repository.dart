import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'shelf_entry.dart';

abstract interface class ShelfRepository {
  Future<List<ShelfEntry>> getAll();
  Future<ShelfEntry> create(ShelfEntry entry);
  Future<ShelfEntry> update(ShelfEntry entry);
  Future<void> delete(String id);
}

class HttpShelfRepository implements ShelfRepository {
  HttpShelfRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<ShelfEntry>> getAll() async {
    final response = await _api.get('/objects');

    try {
      final data = _api.decode(response) as List<dynamic>;

      return data
          .where(
            (item) =>
                item is Map<String, dynamic> &&
                item['data'] is Map<String, dynamic> &&
                (item['data'] as Map<String, dynamic>).containsKey('bookKey'),
          )
          .map((item) => ShelfEntry.fromApi(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (error is ApiException) rethrow;

      throw BadResponseException('shelf: $error');
    }
  }

  @override
  Future<ShelfEntry> create(ShelfEntry entry) async {
    final http.Response response = await _api.post(
      '/objects',
      entry.toApiJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw BadResponseException(
        'shelf: expected 200/201, got ${response.statusCode}',
      );
    }

    return _read(response);
  }

  @override
  Future<ShelfEntry> update(ShelfEntry entry) async {
    final id = entry.id;

    if (id == null) throw const BadResponseException('shelf: missing id');

    final response = await _api.put('/objects/$id', entry.toApiJson());

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw BadResponseException(
        'shelf: expected 200/204, got ${response.statusCode}',
      );
    }

    return _read(response);
  }

  @override
  Future<void> delete(String id) async {
    final response = await _api.delete('/objects/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw BadResponseException(
        'shelf: expected 200/204, got ${response.statusCode}',
      );
    }
  }

  ShelfEntry _read(http.Response response) {
    try {
      return ShelfEntry.fromApi(_api.decode(response) as Map<String, dynamic>);
    } catch (error) {
      if (error is ApiException) rethrow;

      throw BadResponseException('shelf: $error');
    }
  }
}
