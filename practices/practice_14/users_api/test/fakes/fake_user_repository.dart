import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  static const _users = [
    User(
      id: 1,
      name: 'Ada Lovelace',
      username: 'ada',
      email: 'ada@example.com',
      phone: '1-770-736-8031',
      website: 'ada.example.com',
      address: Address(
        street: 'First Street',
        suite: 'Apt. 1',
        city: 'London',
        zipcode: '10001',
        geo: Geo(lat: 51.5074, lng: -0.1278),
      ),
      company: (name: 'Analytical Engine', catchPhrase: 'First programmer'),
    ),
    User(
      id: 2,
      name: 'Alan Turing',
      username: 'alan',
      email: 'alan@example.com',
      phone: '1-770-736-8032',
      website: 'alan.example.com',
      address: Address(
        street: 'Second Street',
        suite: 'Apt. 2',
        city: 'Manchester',
        zipcode: '10002',
        geo: Geo(lat: 53.4808, lng: -2.2426),
      ),
      company: (name: 'Bletchley Park', catchPhrase: 'Code breaker'),
    ),
  ];

  Future<T> _answer<T>(T value) async {
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (fail) {
      throw const NoConnectionException();
    }

    return value;
  }

  @override
  Future<UsersResult> getAll() {
    return _answer((items: _users, fromCache: false));
  }

  @override
  Future<User> getById(int id) async {
    final users = await _answer(_users);

    return users.firstWhere((user) => user.id == id);
  }

  @override
  Future<User> create(User draft) {
    return _answer(draft);
  }
}
