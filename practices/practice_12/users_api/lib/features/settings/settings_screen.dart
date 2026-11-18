import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../profile/profile_screen.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
