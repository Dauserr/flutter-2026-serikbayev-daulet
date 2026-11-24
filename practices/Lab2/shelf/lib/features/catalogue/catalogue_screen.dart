import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/async_views.dart';
import '../../core/widgets/offline_banner.dart';
import '../settings/settings_screen.dart';
import 'book.dart';
import 'book_detail_screen.dart';
import 'catalogue_model.dart';
import 'widgets/book_card.dart';
import 'widgets/wishlist_button.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final _search = TextEditingController(text: 'flutter');
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _searchNow(String value, CatalogueModel model) {
    _debounce?.cancel();
    model.search(value);
  }

  void _onChanged(String value, CatalogueModel model) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      model.search(value);
    });
  }

  void _open(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailScreen(book: book)),
    );
  }

  Widget _data(CatalogueModel model) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth >= 600;
        final Widget list;

        if (isGrid) {
          list = GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth >= 900 ? 3 : 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: model.items.length,
            itemBuilder: (context, index) {
              final book = model.items[index];

              return BookCard(book: book, onTap: () => _open(book));
            },
          );
        } else {
          list = ListView.separated(
            padding: const EdgeInsets.all(12),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: model.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final book = model.items[index];

              return ListTile(
                leading: SizedBox(
                  width: 44,
                  height: 60,
                  child: book.coverUrl == null
                      ? const Icon(Icons.book)
                      : Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.book),
                        ),
                ),
                title: Text(book.title),
                subtitle: Text(
                  book.authors.isEmpty
                      ? 'Unknown author'
                      : book.authors.map((author) => author.name).join(', '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(book),
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () => model.search(model.query),
          child: list,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CatalogueModel>();
    Widget content;

    if (model.loading) {
      content = const LoadingView(message: 'Loading books...');
    } else if (model.error != null) {
      content = ApiErrorView(
        error: model.error!,
        onRetry: () => model.search(model.query),
      );
    } else if (model.items.isEmpty) {
      content = EmptyView(
        message: 'No books found for “${model.query}”.',
        actionLabel: 'Show Flutter books',
        onAction: () {
          _search.text = 'flutter';
          model.search('flutter');
        },
      );
    } else {
      content = _data(model);

      if (model.fromCache) {
        content = Column(
          children: [
            OfflineBanner(onRetry: () => model.search(model.query)),
            Expanded(child: content),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelf'),
        actions: [
          const WishlistButton(),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (value) => _onChanged(value, model),
              onSubmitted: (value) => _searchNow(value, model),
              decoration: InputDecoration(
                hintText: 'Search Open Library',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _search.clear();
                          _searchNow('', model);
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: content,
    );
  }
}
