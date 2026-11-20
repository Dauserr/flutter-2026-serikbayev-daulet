import 'package:flutter/material.dart';

class EmptyUsersView extends StatelessWidget {
  const EmptyUsersView({super.key, this.city});

  final String? city;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(city == null ? 'No users' : 'No users in $city'));
  }
}
