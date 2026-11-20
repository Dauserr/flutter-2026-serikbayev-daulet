import 'package:flutter/material.dart';

import '../user.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isEmpty ? '?' : user.name[0];

    return ListTile(
      leading: CircleAvatar(child: Text(initial)),
      title: Text(user.name),
      subtitle: Text('${user.email} · ${user.address.city}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
