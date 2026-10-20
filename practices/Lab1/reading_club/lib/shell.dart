import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/book.dart';
import 'models/profile.dart';
import 'routes.dart';
import 'tabs/books_tab.dart';
import 'tabs/profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Book> _books = createSeed();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _selectTab(int index) => setState(() => _tab = index);

  void _updateBook(Book book) {
    setState(() {
      _books = [
        for (final current in _books)
          if (current.id == book.id) book else current,
      ];
    });
  }

  void _deleteBook(String id) {
    setState(() {
      _books = _books.where((book) => book.id != id).toList();
    });
  }

  void _updateProfile(Profile profile) {
    setState(() {
      if (_profile.name.isNotEmpty && _profile.name != profile.name) {
        _books = _books
            .map(
              (book) => book.copyWith(
                readers: book.readers
                    .map((name) => name == _profile.name ? profile.name : name)
                    .toSet()
                    .toList(),
              ),
            )
            .toList();
      }
      _profile = profile;
    });
  }

  void _openBook(Book book) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArguments(
        book: book,
        profile: _profile,
        onChanged: _updateBook,
        onDeleted: _deleteBook,
        onProfileRequested: () => _selectTab(2),
      ),
    );
  }

  Future<void> _addBook() async {
    final book = await Navigator.of(context)
        .pushNamed<Book>(Routes.form, arguments: const FormArguments());
    if (book == null || mounted == false) return;
    setState(() => _books = [..._books, book]);
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Books and your profile will return to their starting values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || mounted == false) return;
    setState(() {
      _books = createSeed();
      _profile = const Profile.empty();
    });
  }

  void _about() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reading Club'),
        content: const Text(
          'Browse club books, borrow copies and join discussion meetings. '
          'Data is stored in memory and resets when the app restarts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Reading Club', 'Favourites', 'Profile'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab])),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Reading Club'),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.of(context).pop();
                  _about();
                },
              ),
              ListTile(
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.of(context).pop();
                  _reset();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          BooksTab(
            books: _books,
            onOpen: _openBook,
            onFavourite: (book) =>
                _updateBook(book.copyWith(favourite: book.favourite == false)),
          ),
          BooksTab(
            books: _books,
            favouritesOnly: true,
            onOpen: _openBook,
            onFavourite: (book) =>
                _updateBook(book.copyWith(favourite: book.favourite == false)),
          ),
          ProfileTab(
            profile: _profile,
            books: _books,
            themeMode: widget.themeMode,
            onChanged: _updateProfile,
            onThemeChanged: widget.onThemeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 2
          ? null
          : FloatingActionButton(
              onPressed: _addBook,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Books'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
