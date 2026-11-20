import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/env.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  String get _mode {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: _info,
        builder: (context, snapshot) {
          final info = snapshot.data;

          if (info == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Users'),
                subtitle: const Text('JSONPlaceholder users directory'),
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Version'),
                subtitle: Text('${info.version} (${info.buildNumber})'),
              ),
              ListTile(
                leading: const Icon(Icons.build_outlined),
                title: const Text('Build mode'),
                subtitle: Text(_mode),
              ),
              ListTile(
                leading: const Icon(Icons.layers_outlined),
                title: const Text('Environment'),
                subtitle: Text(Env.name),
              ),
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: const Text('API host'),
                subtitle: Text(Env.host),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Licenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Users',
                    applicationVersion: '${info.version} (${info.buildNumber})',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
