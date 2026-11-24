import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelf/core/api/api_client.dart';
import 'package:shelf/core/storage/secure_store.dart';
import 'package:shelf/features/shelf/shelf_entry.dart';
import 'package:shelf/features/shelf/shelf_repository.dart';

class MemoryStore extends SecureStore {
  @override
  Future<String?> readToken() async => null;
}

ShelfEntry entry() {
  return ShelfEntry(
    id: '7',
    bookKey: '/works/OL1W',
    title: 'Flutter in Action',
    authors: 'Eric Windmill',
    status: 'reading',
    rating: 4,
    pagesRead: 20,
    notes: '',
    targetDate: DateTime(2026, 12, 1),
    finished: false,
  );
}

void main() {
  test('create posts the wrapper and reads the server id', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.headers['Content-Type'], contains('application/json'));

      return http.Response(
        '{"id":"7","name":"Flutter in Action","data":{'
        '"bookKey":"/works/OL1W","title":"Flutter in Action",'
        '"authors":"Eric Windmill","status":"reading","rating":4,'
        '"pagesRead":20,"notes":"","targetDate":"2026-12-01T00:00:00.000",'
        '"finished":false}}',
        200,
      );
    });
    final repo = HttpShelfRepository(
      ApiClient(store: MemoryStore(), client: client),
    );

    final saved = await repo.create(entry().copyWith(id: null));

    expect(saved.id, '7');
    expect(saved.title, 'Flutter in Action');
  });

  test('delete accepts 204', () async {
    final client = MockClient((_) async => http.Response('', 204));
    final repo = HttpShelfRepository(
      ApiClient(store: MemoryStore(), client: client),
    );

    await repo.delete('7');
  });
}
