import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Title'),
              subtitle: Text(book.title),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Author'),
              subtitle: Text(book.author),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Pages'),
              subtitle: Text('${book.pages}'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Year'),
              subtitle: Text(book.year?.toString() ?? 'Year unknown'),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Status'),
              subtitle: Text(book.read ? 'Read' : 'Unread'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(BookAction.toggleRead);
              },
              child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _delete(context),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
