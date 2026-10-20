import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';

class BooksTab extends StatefulWidget {
  const BooksTab({
    super.key,
    required this.books,
    required this.onOpen,
    required this.onFavourite,
    this.favouritesOnly = false,
  });

  final List<Book> books;
  final ValueChanged<Book> onOpen;
  final ValueChanged<Book> onFavourite;
  final bool favouritesOnly;

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  final _search = TextEditingController();
  Genre? _genre;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Book> get _visible {
    final query = _search.text.trim().toLowerCase();
    final books = widget.books.where((book) {
      return (widget.favouritesOnly == false || book.favourite) &&
          (_genre == null || book.genre == _genre) &&
          (_showPast || book.isPast == false) &&
          book.title.toLowerCase().contains(query);
    }).toList();

    books.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
      return a.when.compareTo(b.when);
    });
    return books;
  }

  void _clearFilters() {
    setState(() {
      _search.clear();
      _genre = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = _visible;
    final hasFavourites = widget.books.any((book) => book.favourite);

    Widget card(int index) {
      final book = books[index];
      return BookCard(
        book: book,
        onTap: () => widget.onOpen(book),
        onFavourite: () => widget.onFavourite(book),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _search,
            decoration: InputDecoration(
              labelText: 'Search books',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(() => _search.clear()),
                      icon: const Icon(Icons.clear),
                    ),
            ),
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _genre == null,
                  onSelected: (_) => setState(() => _genre = null),
                ),
                for (final genre in Genre.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      avatar: Icon(genre.icon),
                      label: Text(genre.label),
                      selected: _genre == genre,
                      onSelected: (_) => setState(() => _genre = genre),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: const Text('Include past meetings'),
              selected: _showPast,
              onSelected: (value) => setState(() => _showPast = value),
            ),
          ),
          Expanded(
            child: books.isEmpty
                ? EmptyState(
                    icon: widget.favouritesOnly
                        ? Icons.favorite_border
                        : Icons.search_off,
                    message: widget.favouritesOnly && hasFavourites == false
                        ? 'No favourite books yet'
                        : 'No books match your filters',
                    buttonLabel: 'Clear filters',
                    onPressed: _clearFilters,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 600) {
                        final columns = (constraints.maxWidth / 360).ceil();
                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 88),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 200,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemCount: books.length,
                          itemBuilder: (_, index) => card(index),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: books.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, index) => card(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
