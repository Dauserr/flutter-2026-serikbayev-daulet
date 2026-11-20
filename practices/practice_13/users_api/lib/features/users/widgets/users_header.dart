import 'package:flutter/material.dart';

class UsersHeader extends StatelessWidget implements PreferredSizeWidget {
  const UsersHeader({super.key, required this.onSettings});

  final VoidCallback onSettings;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Users'),
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}
