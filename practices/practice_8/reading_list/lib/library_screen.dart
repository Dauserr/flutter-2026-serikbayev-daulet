import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((book) => book.read).toList(),
  };

  Future<void> _openBook(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute<BookAction>(builder: (_) => DetailScreen(book: book)),
    );

    if (mounted == false) return;

    switch (action) {
      case BookAction.toggleRead:
        setState(() {
          book.read = book.read == false;
        });
        break;
      case BookAction.delete:
        setState(() {
          _books.remove(book);
        });
        break;
      case null:
        break;
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context).push<Book>(
      MaterialPageRoute<Book>(builder: (_) => const AddBookScreen()),
    );

    if (book == null || mounted == false) return;

    setState(() {
      _books.add(book);
    });
  }

  Widget _stat(String label, int value) {
    final text = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value', style: text.headlineSmall),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _stat('Books', _books.length),
                    _stat('Pages', totalPages(_books)),
                    _stat('Unread', unread(_books).length),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final filter in Filter.values)
                  ChoiceChip(
                    label: Text(switch (filter) {
                      Filter.all => 'All',
                      Filter.unread => 'Unread',
                      Filter.read => 'Read',
                    }),
                    selected: _filter == filter,
                    onSelected: (_) {
                      setState(() {
                        _filter = filter;
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final book = visible[index];

                return GestureDetector(
                  onTap: () => _openBook(book),
                  child: BookTile(
                    book: book,
                    onToggle: () {
                      setState(() {
                        book.read = book.read == false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
