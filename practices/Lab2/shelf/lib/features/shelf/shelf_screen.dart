import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/async_views.dart';
import '../settings/settings_model.dart';
import 'shelf_entry.dart';
import 'shelf_form_screen.dart';
import 'shelf_model.dart';

class ShelfScreen extends StatelessWidget {
  const ShelfScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    ShelfModel model,
    ShelfEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete “${entry.title}”?'),
        content: const Text('This removes the entry from your shelf.'),
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

    if (confirmed != true || !context.mounted) return;

    final error = await model.delete(entry.id!);

    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ShelfModel>();
    final settings = context.watch<SettingsModel>();
    final filter = settings.defaultStatus;
    final items = filter == 'all'
        ? model.items
        : model.items.where((item) => item.status == filter).toList();

    final Widget content;

    if (model.loading) {
      content = const LoadingView(message: 'Loading your shelf...');
    } else if (model.error != null) {
      content = ApiErrorView(error: model.error!, onRetry: model.load);
    } else if (items.isEmpty) {
      content = EmptyView(
        message: filter == 'all'
            ? 'Your shelf is empty.'
            : 'No books with status “$filter”.',
        actionLabel: 'Browse catalogue',
        onAction: () => Navigator.of(context).maybePop(),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: model.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entry = items[index];

            return ListTile(
              leading: Icon(
                entry.finished ? Icons.check_circle : Icons.book_outlined,
              ),
              title: Text(entry.title),
              subtitle: Text(
                '${entry.authors} · ${entry.status} · '
                '${entry.pagesRead} pages · ${entry.targetDate.toLocal().toString().split(' ').first}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ShelfFormScreen(entry: entry),
                      ),
                    );
                  } else if (value == 'delete') {
                    await _delete(context, model, entry);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My shelf')),
      body: content,
    );
  }
}
