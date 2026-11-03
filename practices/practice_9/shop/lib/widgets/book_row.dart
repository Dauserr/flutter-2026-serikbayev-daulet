import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/cart.dart';

class BookRow extends StatelessWidget {
  const BookRow({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final added = context.watch<Cart>().items.contains(book);

    return ListTile(
      title: Text(book.title),
      subtitle: Text('${book.author} · ${book.price} ₸'),
      trailing: added
          ? const Text('Added')
          : OutlinedButton(
              onPressed: () {
                final ok = context.read<Cart>().add(book);

                if (ok) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Added')));
                }
              },
              child: const Text('Add'),
            ),
    );
  }
}
