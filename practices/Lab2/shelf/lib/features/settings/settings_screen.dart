import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../about/about_screen.dart';
import '../auth/auth_model.dart';
import '../profile/profile_screen.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const statuses = ['all', 'want', 'reading', 'read'];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Saved for the next launch'),
            value: settings.dark,
            onChanged: (value) {
              unawaited(settings.setDark(value));
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              key: ValueKey(settings.defaultStatus),
              initialValue: settings.defaultStatus,
              decoration: const InputDecoration(
                labelText: 'Default shelf filter',
              ),
              items: [
                for (final status in statuses)
                  DropdownMenuItem(
                    value: status,
                    child: Text(status == 'all' ? 'All books' : status),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                unawaited(settings.setDefaultStatus(value));
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Profile photo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              await context.read<AuthModel>().logout();

              if (!context.mounted) return;

              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
