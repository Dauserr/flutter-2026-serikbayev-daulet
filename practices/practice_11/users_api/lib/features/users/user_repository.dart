import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
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

  Future<User> getById(int id) async {
    final http.Response response = await _api.get('/users/$id');

    try {
      return User.fromJson(_api.decode(response) as Map<String, dynamic>);
    } catch (error) {
      if (error is BadResponseException) rethrow;

      throw BadResponseException('users/$id: $error');
    }
  }

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
