import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/format.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavourite,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (:taken, :free) = book.places;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: book.genre.color(colors),
                    child: Icon(book.genre.icon, color: colors.onSurface),
                  ),
                  if (book.isFull || free <= 5)
                    Positioned(
                      right: -8,
                      bottom: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.isFull ? 'FULL' : '$free left',
                          style: text.labelSmall?.copyWith(
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(formatDateTime(book.when), style: text.bodySmall),
                    Text(
                      book.place,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$taken / ${book.limit} borrowed',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: book.favourite ? 'Remove favourite' : 'Add favourite',
                onPressed: onFavourite,
                icon: Icon(
                  book.favourite ? Icons.favorite : Icons.favorite_border,
                ),
                color: book.favourite
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
