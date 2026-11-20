import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  UsersCache({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directory;

  Future<File> _file() async {
    final directory = await _directory();
    return File('${directory.path}/users.json');
  }

  Future<void> save(List<User> users) async {
    final file = await _file();
    final data = [for (final user in users) user.toJson()];

    await file.writeAsString(jsonEncode(data));
  }

  Future<List<User>?> load() async {
    final file = await _file();

    if (!await file.exists()) return null;

    final data = jsonDecode(await file.readAsString()) as List<dynamic>;

    return data
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
