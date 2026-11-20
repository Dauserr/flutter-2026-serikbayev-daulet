import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/api_client.dart';
import '../about/about_screen.dart';
import '../auth/auth_model.dart';
import '../profile/profile_screen.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editHost(BuildContext context) async {
    final api = context.read<ApiClient>();
    final controller = TextEditingController(text: api.host);
    final host = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Developer: API host'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Host'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (host == null || host.isEmpty || !context.mounted) return;

    api.host = host;
    await SharedPreferencesAsync().setString('apiHost', host);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('API host set to $host')));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>();

    final cities = users.items.map((user) => user.address.city).toSet();
    final selectedCity = settings.city;

    if (selectedCity != null) {
      cities.add(selectedCity);
    }

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
              key: ValueKey(selectedCity ?? ''),
              initialValue: selectedCity ?? '',
              decoration: const InputDecoration(labelText: 'City filter'),
              items: [
                const DropdownMenuItem(value: '', child: Text('All cities')),
                for (final city in cities.toList()..sort())
                  DropdownMenuItem(value: city, child: Text(city)),
              ],
              onChanged: (value) {
                unawaited(
                  settings.setCity(
                    value == null || value.isEmpty ? null : value,
                  ),
                );
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
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.dns_outlined),
              title: const Text('Developer: API host'),
              subtitle: Text(context.read<ApiClient>().host),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editHost(context),
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
