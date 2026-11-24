import 'package:flutter_test/flutter_test.dart';

import 'package:warmup_2_list/main.dart';

void main() {
  test('loading a failing repository sets error', () async {
    final model = ListModel(FakeRepository(fail: true));

    await model.load();

    expect(model.error, isNotNull);
    expect(model.items, isEmpty);
    expect(model.loading, isFalse);
  });

  test('loading a good repository fills items', () async {
    final model = ListModel(FakeRepository());

    await model.load();

    expect(model.error, isNull);
    expect(model.items, hasLength(2));
    expect(model.state, ListState.data);
  });
}
