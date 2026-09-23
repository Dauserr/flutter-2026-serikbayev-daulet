import 'package:flutter/material.dart';

import 'data.dart';
import 'profile_header.dart';
import 'info_row.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: Center(
          child: Column(
            children: [
              ProfileHeader(name: myName, university: myUniversity),
              for (final fact in facts)
                InfoRow(label: fact.label, value: fact.value),
            ],
          ),
        ),
      ),
    );
  }
}
