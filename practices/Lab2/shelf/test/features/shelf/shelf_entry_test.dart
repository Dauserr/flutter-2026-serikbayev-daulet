import 'package:flutter_test/flutter_test.dart';

import 'package:shelf/features/shelf/shelf_entry.dart';

void main() {
  test('parses an API wrapper and round-trips its data', () {
    final entry = ShelfEntry.fromApi({
      'id': '42',
      'name': 'Flutter in Action',
      'data': {
        'bookKey': '/works/OL1W',
        'title': 'Flutter in Action',
        'authors': 'Eric Windmill',
        'status': 'reading',
        'rating': 4,
        'pagesRead': 120,
        'notes': 'Chapter 3',
        'targetDate': '2026-12-01T00:00:00.000',
        'finished': false,
      },
    });

    expect(entry.id, '42');
    expect(entry.status, 'reading');
    expect(entry.rating, 4);
    expect(ShelfEntry.fromJson(entry.toJson()).title, 'Flutter in Action');
  });

  test('throws when the API omits the book key', () {
    expect(
      () => ShelfEntry.fromApi({
        'id': '1',
        'data': {
          'title': 'Broken',
          'authors': 'Nobody',
          'status': 'want',
          'pagesRead': 0,
          'targetDate': '2026-12-01T00:00:00.000',
        },
      }),
      throwsA(isA<TypeError>()),
    );
  });
}
