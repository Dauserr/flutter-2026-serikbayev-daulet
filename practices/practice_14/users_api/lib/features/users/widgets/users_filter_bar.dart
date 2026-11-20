import 'package:flutter/material.dart';

class UsersFilterBar extends StatelessWidget {
  const UsersFilterBar({super.key, required this.city, required this.onClear});

  final String city;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.secondaryContainer,
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Icon(Icons.filter_alt_outlined, color: colors.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'City: $city',
              style: TextStyle(color: colors.onSecondaryContainer),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}
