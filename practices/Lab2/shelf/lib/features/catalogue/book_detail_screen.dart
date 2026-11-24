import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shelf/shelf_form_screen.dart';
import 'book.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _openLibrary(BuildContext context) async {
    final opened = await launchUrl(Uri.parse(book.openLibraryUrl));

    if (!context.mounted) return;

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No app can open this link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cover = book.coverUrl;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cover != null)
            Center(
              child: Image.network(
                cover,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(Icons.book, size: 96),
              ),
            ),
          const SizedBox(height: 16),
          Text(book.title, style: text.headlineSmall),
          const SizedBox(height: 8),
          for (final author in book.authors)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(author.name),
              subtitle: author.key == null ? null : Text(author.key!),
            ),
          if (book.authors.isEmpty) const Text('Unknown author'),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('First published'),
            subtitle: Text(book.firstPublishYear?.toString() ?? 'Unknown'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.copy_all_outlined),
            title: const Text('Editions'),
            subtitle: Text('${book.editionCount}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('E-book access'),
            subtitle: Text(book.ebookAccess),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: const Text('Languages'),
            subtitle: Text(
              book.languages.isEmpty ? 'Unknown' : book.languages.join(', '),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ShelfFormScreen(book: book),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add to my shelf'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openLibrary(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in Open Library'),
          ),
        ],
      ),
    );
  }
}
