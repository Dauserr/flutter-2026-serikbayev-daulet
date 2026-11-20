import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
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

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri);

    if (!context.mounted) return;

    if (!opened) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  Future<void> _copyToken(BuildContext context) async {
    final token = context.read<AuthModel>().token;

    if (token == null) return;

    await Clipboard.setData(ClipboardData(text: token));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Token copied')));
  }

  @override
  Widget build(BuildContext context) {
    final website = user.website;

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _tile(Icons.badge_outlined, 'ID', '${user.id}'),
          _tile(Icons.person_outline, 'Name', user.name),
          _tile(Icons.alternate_email, 'Username', user.username),
          _tile(
            Icons.email_outlined,
            'Email',
            user.email,
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          _tile(
            Icons.phone_outlined,
            'Phone',
            '${user.phone} (${user.phoneDigits})',
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          _tile(
            Icons.language_outlined,
            'Website',
            website ?? '-',
            onTap: website == null
                ? null
                : () => _open(context, Uri.parse('https://$website')),
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
          if (kDebugMode) ...[
            const Divider(),
            _tile(
              Icons.key_outlined,
              'Debug token',
              'Copy token to clipboard',
              onTap: () => _copyToken(context),
            ),
          ],
        ],
      ),
    );
  }
}
