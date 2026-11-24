import '../../core/api/api_exception.dart';
import 'shelf_entry.dart';
import 'shelf_repository.dart';

class FakeShelfRepository implements ShelfRepository {
  FakeShelfRepository({this.fail = false, this.delay = Duration.zero});

  final bool fail;
  final Duration delay;

  final List<ShelfEntry> _items = [
    ShelfEntry(
      id: '1',
      bookKey: '/works/OL1W',
      title: 'Flutter in Action',
      authors: 'Eric Windmill',
      status: 'reading',
      rating: 4,
      pagesRead: 120,
      notes: 'State management chapter',
      targetDate: DateTime(2026, 12, 1),
      finished: false,
    ),
    ShelfEntry(
      id: '2',
      bookKey: '/works/OL2W',
      title: 'The Pragmatic Programmer',
      authors: 'Andrew Hunt',
      status: 'want',
      rating: null,
      pagesRead: 0,
      notes: '',
      targetDate: DateTime(2026, 12, 20),
      finished: false,
    ),
  ];

  Future<void> _pause() async {
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (fail) throw const NoConnectionException();
  }

  @override
  Future<List<ShelfEntry>> getAll() async {
    await _pause();
    return List.unmodifiable(_items);
  }

  @override
  Future<ShelfEntry> create(ShelfEntry entry) async {
    await _pause();
    final saved = entry.copyWith(id: '${_items.length + 1}');
    _items.add(saved);
    return saved;
  }

  @override
  Future<ShelfEntry> update(ShelfEntry entry) async {
    await _pause();
    final index = _items.indexWhere((item) => item.id == entry.id);

    if (index < 0) throw const NotFoundException();

    _items[index] = entry;
    return entry;
  }

  @override
  Future<void> delete(String id) async {
    await _pause();
    _items.removeWhere((item) => item.id == id);
  }
}
