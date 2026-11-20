import 'package:flutter/material.dart';

import '../user.dart';
import 'user_tile.dart';

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

        return UserTile(user: user, onTap: () => onTap(user));
      },
    );
  }
}
