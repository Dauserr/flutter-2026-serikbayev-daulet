import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shelf/shelf_model.dart';
import '../../shelf/shelf_screen.dart';

class WishlistButton extends StatelessWidget {
  const WishlistButton({super.key});

  @override
  Widget build(BuildContext context) {
    // select: the badge depends only on the shelf count, not on the list.
    final count = context.select<ShelfModel, int>(
      (shelf) => shelf.items.length,
    );

    return IconButton(
      tooltip: 'My shelf',
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => const ShelfScreen()));
      },
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.collections_bookmark_outlined),
      ),
    );
  }
}
