import 'package:flutter_test/flutter_test.dart';

import 'package:shelf/core/api/api_exception.dart';
import 'package:shelf/features/shelf/fake_shelf_repository.dart';
import 'package:shelf/features/shelf/shelf_entry.dart';
import 'package:shelf/features/shelf/shelf_model.dart';

void main() {
  test('load fills the shelf', () async {
    final model = ShelfModel(FakeShelfRepository());

    await model.load();

    expect(model.items, hasLength(2));
    expect(model.error, isNull);
    expect(model.loading, isFalse);
  });

  test('NoConnection sets the shelf error', () async {
    final model = ShelfModel(FakeShelfRepository(fail: true));

    await model.load();

    expect(model.error, isA<NoConnectionException>());
    expect(model.loading, isFalse);
  });

  test('save creates an entry and reloads the server list', () async {
    final model = ShelfModel(FakeShelfRepository());
    await model.load();

    final error = await model.save(
      ShelfEntry(
        id: null,
        bookKey: '/works/OL3W',
        title: 'New Book',
        authors: 'New Author',
        status: 'want',
        rating: null,
        pagesRead: 0,
        notes: '',
        targetDate: DateTime(2026, 12, 1),
        finished: false,
      ),
    );

    expect(error, isNull);
    expect(model.items, hasLength(3));
    expect(model.items.last.title, 'New Book');
  });
}
