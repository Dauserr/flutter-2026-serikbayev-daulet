import 'data.dart';
import 'models.dart';

void main() {
  final books = rawBooks.map(Book.fromJson).toList();

  for (final book in books) {
    print(book);
    print('Long book: ${book.isLong}');
  }
}