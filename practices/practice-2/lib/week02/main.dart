import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  for (final data in rawBooks) {
    library.add(Book.fromJson(data));
  }

  library.add(
    const Magazine(
      title: 'Dart Monthly',
      year: 2026,
      issue: 12,
    ),
  );

  library.open();

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);

  print(library.titles);
  print(library.booksAfter2010);
  print(library.averagePages);
  print(library.booksPerAuthor);
  print(library.authorNames);
  print(library.genres);

  for (final line in library.displayList) {
    print(line);
  }

  print(stats);
  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('Shelf needs repair')));
}