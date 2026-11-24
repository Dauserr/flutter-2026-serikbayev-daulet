import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'book.dart';

class BookCache {
  BookCache({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directory;

  Future<File> _file() async {
    final directory = await _directory();
    return File('${directory.path}/books.json');
  }

  Future<void> save(List<Book> books) async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode([for (final book in books) book.toJson()]),
    );
  }

  Future<List<Book>?> load() async {
    final file = await _file();

    if (!await file.exists()) return null;

    final data = jsonDecode(await file.readAsString()) as List<dynamic>;

    return data
        .map((item) => Book.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
