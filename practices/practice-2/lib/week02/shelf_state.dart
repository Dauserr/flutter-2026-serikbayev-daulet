Bimport 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

class Empty extends ShelfState {
  const Empty();
}

class Ready extends ShelfState {
  final List<Book> books;

  const Ready(this.books);
}

class Broken extends ShelfState {
  final String message;

  const Broken(this.message);
}

String describe(ShelfState state) {
  return switch (state) {
    Empty() => 'The shelf is empty',
    Ready(books: final books) => 'The shelf has ${books.length} books',
    Broken(message: final message) => 'The shelf has a problem: $message',
  };
}

({int count, double avgPages}) statsOf(List<Book> books) {
  final totalPages = books.fold<int>(0, (total, book) => total + book.pages);

  return (
  count: books.length,
  avgPages: books.isEmpty ? 0 : totalPages / books.length,
  );
}