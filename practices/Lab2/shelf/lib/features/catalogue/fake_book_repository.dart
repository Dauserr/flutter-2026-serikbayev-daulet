import '../../core/api/api_exception.dart';
import 'book.dart';
import 'book_repository.dart';

class FakeBookRepository implements BookRepository {
  FakeBookRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  static const books = [
    Book(
      key: '/works/OL1W',
      title: 'Flutter in Action',
      authors: [BookAuthor(name: 'Eric Windmill', key: 'OL1A')],
      coverId: null,
      firstPublishYear: 2019,
      editionCount: 2,
      ebookAccess: 'borrowable',
      languages: ['eng'],
    ),
    Book(
      key: '/works/OL2W',
      title: 'The Pragmatic Programmer',
      authors: [BookAuthor(name: 'Andrew Hunt', key: 'OL2A')],
      coverId: null,
      firstPublishYear: 1999,
      editionCount: 4,
      ebookAccess: 'printdisabled',
      languages: ['eng'],
    ),
  ];

  @override
  Future<BooksResult> search(String query) async {
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (fail) throw const NoConnectionException();

    final search = query.trim().toLowerCase();
    final matches = search.isEmpty
        ? books
        : books
              .where((book) => book.title.toLowerCase().contains(search))
              .toList();

    return (items: matches, fromCache: false);
  }
}
