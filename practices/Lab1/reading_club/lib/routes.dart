import 'package:flutter/material.dart';

import 'models/book.dart';
import 'models/profile.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArguments {
  const DetailArguments({
    required this.book,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onProfileRequested,
  });

  final Book book;
  final Profile profile;
  final ValueChanged<Book> onChanged;
  final ValueChanged<String> onDeleted;
  final VoidCallback onProfileRequested;
}

class FormArguments {
  const FormArguments({this.book});
  final Book? book;
}
