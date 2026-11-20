import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

abstract interface class UserRepository {
  Future<UsersResult> getAll();
  Future<User> getById(int id);
  Future<User> create(User draft);
}

class HttpUserRepository implements UserRepository {
  HttpUserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  @override
  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetchUsers();

      await _cache.save(fresh);

      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();

      if (saved == null) rethrow;

      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetchUsers() async {
    final http.Response response = await _api.get('/users');

    try {
      final data = _api.decode(response) as List<dynamic>;

      return data
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      if (error is BadResponseException) rethrow;

      throw BadResponseException('users: $error');
    }
  }

  @override
  Future<User> getById(int id) async {
    final http.Response response = await _api.get('/users/$id');

    try {
      return User.fromJson(_api.decode(response) as Map<String, dynamic>);
    } catch (error) {
      if (error is BadResponseException) rethrow;

      throw BadResponseException('users/$id: $error');
    }
  }

  @override
  Future<User> create(User draft) async {
    final http.Response response = await _api.post('/users', draft.toJson());

    if (response.statusCode != 201) {
      throw BadResponseException(
        'users: expected 201, got ${response.statusCode}',
      );
    }

    try {
      return User.fromJson(_api.decode(response) as Map<String, dynamic>);
    } catch (error) {
      if (error is BadResponseException) rethrow;

      throw BadResponseException('users: $error');
    }
  }
}
