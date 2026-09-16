import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;

  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }

    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  void open() {
    openedAt = DateTime.now();
  }

  String buildReport() {
    return _cachedReport ??= items.map((item) => item.describe()).join('\n');
  }

  List<String> get titles => items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010).toList();

  double get averagePages {
    final books = items.whereType<Book>().toList();

    return books.isEmpty
        ? 0
        : books.fold<int>(0, (total, book) => total + book.pages) / books.length;
  }

  Map<String, int> get booksPerAuthor => {
    for (final book in items.whereType<Book>())
      book.author.name: items
          .whereType<Book>()
          .where((other) => other.author.name == book.author.name)
          .length,
  };

  Set<String> get authorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get genres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',
    for (final book in items.whereType<Book>())
      '${book.title} (${book.year})',
    ...authorNames,
    if (items.whereType<Book>().any((book) => book.pages == 0))
      '(incomplete data)',
  ];
}