import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelf/core/api/api_client.dart';
import 'package:shelf/core/api/api_exception.dart';
import 'package:shelf/core/storage/secure_store.dart';
import 'package:shelf/features/catalogue/book_cache.dart';
import 'package:shelf/features/catalogue/book_repository.dart';

class MemoryStore extends SecureStore {
  @override
  Future<String?> readToken() async => null;
}

BookRepository repository(MockClient client) {
  return HttpBookRepository(
    ApiClient(store: MemoryStore(), client: client),
    BookCache(directory: () async => Directory.systemTemp),
  );
}

void main() {
  test('maps a 404 to NotFoundException', () async {
    final repo = repository(MockClient((_) async => http.Response('{}', 404)));

    await expectLater(
      repo.search('flutter'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('maps a 500 to ServerException', () async {
    final repo = repository(
      MockClient((_) async => http.Response('server down', 500)),
    );

    await expectLater(repo.search('flutter'), throwsA(isA<ServerException>()));
  });

  test('maps SocketException to NoConnectionException', () async {
    final repo = repository(
      MockClient((_) async {
        throw const SocketException('down');
      }),
    );

    await expectLater(
      repo.search('flutter'),
      throwsA(isA<NoConnectionException>()),
    );
  });
}
