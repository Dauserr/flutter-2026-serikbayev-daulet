import 'data.dart';
import 'models.dart';

void main() {
  final books = rawBooks.map(Book.fromJson).toList();

  final items = <LibraryItem>[
    ...books,
    const Magazine(
      title: 'Dart Monthly',
      year: 2026,
      issue: 12,
    ),
    const Ghost(
      title: 'Lost Manuscript',
      year: 1985,
    ),
  ];

  for (final item in items) {
    print(item.describe());
    print('Old: ${item.isOld}');

    if (item is Book) {
      print(item.borrowLabel());
      print('Long: ${item.isLong}');
    }

    print('---');
  }
}