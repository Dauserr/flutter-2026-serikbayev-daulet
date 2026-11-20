import 'package:flutter_test/flutter_test.dart';

import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/users_model.dart';

import '../../fakes/fake_user_repository.dart';

void main() {
  group('UsersModel', () {
    test('load fills items', () async {
      final model = UsersModel(FakeUserRepository());

      await model.load();

      expect(model.items, hasLength(2));
      expect(model.loading, isFalse);
      expect(model.error, isNull);
    });

    test('load sets NoConnection error', () async {
      final model = UsersModel(FakeUserRepository(fail: true));

      await model.load();

      expect(model.error, isA<NoConnectionException>());
      expect(model.loading, isFalse);
    });
  });
}
