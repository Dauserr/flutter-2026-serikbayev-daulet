import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/book.dart';
import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _clear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Every book will be removed from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<Cart>().clear();
    }
  }

  Widget _row(Cart cart, Book book) {
    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author} · ${book.price} ₸'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Add one',
            onPressed: () => cart.increment(book),
            icon: const Icon(Icons.add),
          ),
          Text('x${cart.qtyOf(book)}'),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => cart.remove(book),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            tooltip: 'Clear cart',
            onPressed: () => _clear(context),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<Cart>(
              builder: (context, cart, _) {
                final items = cart.items;

                if (items.isEmpty) {
                  return const Center(child: Text('Cart is empty'));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _row(cart, items[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<Cart>(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined),
                  SizedBox(width: 8),
                  Text('Total'),
                ],
              ),
              builder: (context, cart, child) => Row(
                children: [
                  child!,
                  const Spacer(),
                  Text(
                    '${cart.total} ₸',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
