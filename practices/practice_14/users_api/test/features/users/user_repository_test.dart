import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';

const userJson = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

class MemoryStore extends SecureStore {
  @override
  Future<String?> readToken() async => null;
}

HttpUserRepository repository(MockClient client) {
  return HttpUserRepository(
    ApiClient(store: MemoryStore(), client: client),
    UsersCache(directory: () async => Directory.systemTemp),
  );
}

void main() {
  group('HttpUserRepository', () {
    test('maps 404 to NotFoundException', () async {
      final repo = repository(
        MockClient((_) async => http.Response('{"error":"gone"}', 404)),
      );

      await expectLater(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('maps 500 to ServerException', () async {
      final repo = repository(
        MockClient((_) async => http.Response('server down', 500)),
      );

      await expectLater(repo.getById(99), throwsA(isA<ServerException>()));
    });

    test('maps SocketException to NoConnectionException', () async {
      final repo = repository(
        MockClient((_) async {
          throw const SocketException('down');
        }),
      );

      await expectLater(
        repo.getById(99),
        throwsA(isA<NoConnectionException>()),
      );
    });

    test('maps a broken lat to BadResponseException', () async {
      final badJson = userJson.replaceFirst('"-37.3159"', '-37.3159');
      final repo = repository(
        MockClient((_) async => http.Response('[$badJson]', 200)),
      );

      await expectLater(repo.getAll(), throwsA(isA<BadResponseException>()));
    });
  });
}
