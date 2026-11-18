import 'package:flutter/material.dart';

import '../user.dart';

class UserList extends StatelessWidget {
  const UserList({super.key, required this.users, required this.onTap});

  final List<User> users;
  final ValueChanged<User> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        final initial = user.name.isEmpty ? '?' : user.name[0];

        return ListTile(
          leading: CircleAvatar(child: Text(initial)),
          title: Text(user.name),
          subtitle: Text('${user.email} · ${user.address.city}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onTap(user),
        );
      },
    );
  }
}
