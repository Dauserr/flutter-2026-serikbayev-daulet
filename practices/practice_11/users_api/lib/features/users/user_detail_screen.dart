import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Widget _tile(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _tile(Icons.badge_outlined, 'ID', '${user.id}'),
          _tile(Icons.person_outline, 'Name', user.name),
          _tile(Icons.alternate_email, 'Username', user.username),
          _tile(Icons.email_outlined, 'Email', user.email),
          _tile(
            Icons.phone_outlined,
            'Phone',
            '${user.phone} (${user.phoneDigits})',
            onTap: () {},
          ),
          _tile(
            Icons.language_outlined,
            'Website',
            user.website ?? '-',
            onTap: () {},
          ),
          const Divider(),
          _tile(Icons.home_outlined, 'Street', user.address.street),
          _tile(Icons.meeting_room_outlined, 'Suite', user.address.suite),
          _tile(Icons.location_city_outlined, 'City', user.address.city),
          _tile(
            Icons.markunread_mailbox_outlined,
            'Zipcode',
            user.address.zipcode,
          ),
          _tile(
            Icons.my_location_outlined,
            'Geo',
            '${user.address.geo.lat}, ${user.address.geo.lng}',
          ),
          const Divider(),
          _tile(Icons.business_outlined, 'Company', user.company.name),
          _tile(
            Icons.format_quote_outlined,
            'Catch phrase',
            user.company.catchPhrase,
          ),
        ],
      ),
    );
  }
}
