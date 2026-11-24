import 'package:flutter_test/flutter_test.dart';

import 'package:shelf/features/catalogue/book.dart';

const bookJson = r'''
{
  "key": "/works/OL28961766W",
  "title": "Flutter Apprentice",
  "author_name": ["raywenderlich Tutorial Team", "Mike Katz"],
  "author_key": ["OL8010072A", "OL7498034A"],
  "cover_i": 14780498,
  "first_publish_year": 2021,
  "edition_count": 4,
  "ebook_access": "no_ebook",
  "language": ["eng"]
}
''';

void main() {
  test('parses a search result with nested authors', () {
    final book = Book.fromJson(const {
      'key': '/works/OL28961766W',
      'title': 'Flutter Apprentice',
      'author_name': ['raywenderlich Tutorial Team', 'Mike Katz'],
      'author_key': ['OL8010072A', 'OL7498034A'],
      'cover_i': 14780498,
      'first_publish_year': 2021,
      'edition_count': 4,
      'ebook_access': 'no_ebook',
      'language': ['eng'],
    });

    expect(book.title, 'Flutter Apprentice');
    expect(book.authors, hasLength(2));
    expect(book.authors.first.name, 'raywenderlich Tutorial Team');
    expect(book.authors[1].key, 'OL7498034A');
    expect(book.firstPublishYear, 2021);
  });

  test('round-trips through JSON', () {
    final book = Book.fromJson(const {
      'key': '/works/OL1W',
      'title': 'A Book',
      'author_name': ['An Author'],
      'author_key': ['OL1A'],
      'edition_count': 1,
      'ebook_access': 'unknown',
      'language': ['eng'],
    });

    expect(Book.fromJson(book.toJson()).title, book.title);
    expect(Book.fromJson(book.toJson()).authors.first.name, 'An Author');
  });

  test('throws when edition_count is a string', () {
    expect(
      () => Book.fromJson(const {
        'key': '/works/OL1W',
        'title': 'A Book',
        'edition_count': 'one',
      }),
      throwsA(isA<TypeError>()),
    );
  });
}
