import 'package:flutter/material.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'widgets/book_row.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Book> get _visible {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return books;

    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
    }).toList();
  }

  void _clearSearch() {
    _search.clear();
    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search books',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close),
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
        ),
      ),
      body: visible.isEmpty
          ? const Center(child: Text('Nothing found'))
          : ListView.builder(
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final book = visible[index];

                return BookRow(book: book);
              },
            ),
    );
  }
}
