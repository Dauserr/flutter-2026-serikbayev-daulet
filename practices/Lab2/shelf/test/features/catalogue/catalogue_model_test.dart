import 'package:flutter_test/flutter_test.dart';

import 'package:shelf/core/api/api_exception.dart';
import 'package:shelf/features/catalogue/catalogue_model.dart';
import 'package:shelf/features/catalogue/fake_book_repository.dart';

void main() {
  test('search fills the catalogue', () async {
    final model = CatalogueModel(FakeBookRepository());

    await model.search('flutter');

    expect(model.items, hasLength(1));
    expect(model.items.first.title, 'Flutter in Action');
    expect(model.loading, isFalse);
    expect(model.error, isNull);
  });

  test('NoConnection sets the catalogue error', () async {
    final model = CatalogueModel(FakeBookRepository(fail: true));

    await model.search('flutter');

    expect(model.error, isA<NoConnectionException>());
    expect(model.loading, isFalse);
  });
}
