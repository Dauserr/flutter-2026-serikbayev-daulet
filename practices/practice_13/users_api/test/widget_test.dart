import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/users/new_user_screen.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_cache.dart';
import 'package:users_api/features/users/users_model.dart';

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
  MemoryStore([this._token]);

  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}

class MemoryUsersCache extends UsersCache {
  MemoryUsersCache() : super(directory: () async => Directory.systemTemp);

  List<User>? _saved;

  @override
  Future<void> save(List<User> users) async {
    _saved = users;
  }

  @override
  Future<List<User>?> load() async => _saved;
}

User parseUser({int id = 1}) {
  final data = jsonDecode(userJson) as Map<String, dynamic>;
  data['id'] = id;
  return User.fromJson(data);
}

ApiClient mockApi({MemoryStore? store}) {
  return ApiClient(
    store: store ?? MemoryStore(),
    client: MockClient((request) async {
      if (request.method == 'POST') {
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        data['id'] = 11;
        return http.Response(jsonEncode(data), 201);
      }

      if (request.url.path == '/users/999') {
        return http.Response('{}', 404);
      }

      if (request.url.path == '/users/500') {
        return http.Response('server down', 500);
      }

      if (request.url.path == '/users/1') {
        return http.Response(userJson, 200);
      }

      return http.Response('[$userJson]', 200);
    }),
  );
}

Future<UsersCache> emptyCache() async {
  final directory = await Directory.systemTemp.createTemp('users_api_test');
  addTearDown(() => directory.delete(recursive: true));
  return UsersCache(directory: () async => directory);
}

void main() {
  test('User round-trips through JSON', () {
    final user = parseUser();

    expect(user.name, 'Leanne Graham');
    expect(user.address.geo.lat, -37.3159);
    expect(user.website, 'hildegard.org');
    expect(user.company.name, 'Romaguera-Crona');
    expect(user.phoneDigits, '1770736803156442');
    expect(User.fromJson(user.toJson()), user);
  });

  test('ApiClient sends the stored token', () async {
    String? authorization;
    final api = ApiClient(
      store: MemoryStore('tok_test'),
      client: MockClient((request) async {
        authorization = request.headers['Authorization'];
        return http.Response('[]', 200);
      }),
    );

    await api.get('/users');

    expect(authorization, 'Bearer tok_test');
  });

  test('repository decodes a list and one user', () async {
    final repo = UserRepository(mockApi(), await emptyCache());

    final result = await repo.getAll();
    final user = await repo.getById(1);

    expect(result.items, hasLength(1));
    expect(result.fromCache, isFalse);
    expect(user.name, 'Leanne Graham');
  });

  test('repository maps statuses and invalid JSON', () async {
    final repo = UserRepository(mockApi(), await emptyCache());

    await expectLater(repo.getById(999), throwsA(isA<NotFoundException>()));
    await expectLater(repo.getById(500), throwsA(isA<ServerException>()));

    final badRepo = UserRepository(
      ApiClient(
        store: MemoryStore(),
        client: MockClient((_) async => http.Response('not json', 200)),
      ),
      await emptyCache(),
    );

    await expectLater(badRepo.getAll(), throwsA(isA<BadResponseException>()));
  });

  test('repository returns the cache when offline', () async {
    final cache = await emptyCache();
    final online = UserRepository(mockApi(), cache);

    await online.getAll();

    final offline = UserRepository(
      ApiClient(
        store: MemoryStore(),
        client: MockClient((_) async {
          throw const SocketException('offline');
        }),
      ),
      cache,
    );

    final result = await offline.getAll();

    expect(result.fromCache, isTrue);
    expect(result.items, hasLength(1));
  });

  test('repository creates a user with the server id', () async {
    final repo = UserRepository(mockApi(), await emptyCache());

    final created = await repo.create(parseUser(id: 0));

    expect(created.id, 11);
    expect(created.name, 'Leanne Graham');
  });

  test('model loads and inserts a created user', () async {
    final repo = UserRepository(mockApi(), await emptyCache());
    final model = UsersModel(repo);

    await model.load();

    expect(model.loading, isFalse);
    expect(model.error, isNull);
    expect(model.items, hasLength(1));
    expect(model.fromCache, isFalse);

    final error = await model.create(parseUser(id: 0));

    expect(error, isNull);
    expect(model.items, hasLength(2));
    expect(model.items.first.id, 11);
  });

  testWidgets('new user form sends one POST while saving', (tester) async {
    var posts = 0;
    final client = MockClient((request) async {
      if (request.method != 'POST') {
        return http.Response('[$userJson]', 200);
      }

      posts++;

      await Future<void>.delayed(const Duration(seconds: 1));

      final data = jsonDecode(request.body) as Map<String, dynamic>;
      data['id'] = 11;

      return http.Response(jsonEncode(data), 201);
    });

    final model = UsersModel(
      UserRepository(
        ApiClient(store: MemoryStore(), client: client),
        MemoryUsersCache(),
      ),
    );
    await model.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: NewUserScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Daulet');
    await tester.enterText(find.byType(TextFormField).at(1), 'daulet');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'daulet@example.com',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(posts, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(posts, 1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(posts, 1);
    expect(model.items.first.name, 'Daulet');
  });
}
