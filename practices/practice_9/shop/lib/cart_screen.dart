import 'package:flutter/material.dart';

import 'main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});

  final List<Book> items;
  final void Function(Book) onRemove;

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0, (sum, book) => sum + book.price);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final book = items[index];

                return ListTile(
                  title: Text(book.title),
                  subtitle: Text('${book.author} · ${book.price} ₸'),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    onPressed: () => onRemove(book),
                    icon: const Icon(Icons.close),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Total', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text('$total ₸', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
