import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async students')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.list_alt)),
              title: const Text('By hand'),
              subtitle: const Text('Three fields, try / catch, mounted'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(context, const StudentsScreen()),
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.auto_awesome)),
              title: const Text('FutureBuilder'),
              subtitle: const Text('Stored Future and a compact Switch'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(context, const StudentsFutureScreen()),
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.timer_outlined)),
              title: const Text('Countdown'),
              subtitle: const Text(
                'StreamBuilder and a cancelled subscription',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(context, const CountdownScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
