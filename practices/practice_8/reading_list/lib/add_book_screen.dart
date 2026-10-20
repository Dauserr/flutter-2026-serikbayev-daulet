import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_title, _author, _pages, _year]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _unfocus(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _save() {
    if (_formKey.currentState!.validate() == false) return;

    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );

    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'Title must have at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _author,
                decoration: const InputDecoration(labelText: 'Author'),
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pages,
                decoration: const InputDecoration(labelText: 'Pages'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: _unfocus,
                validator: (value) {
                  final number = int.tryParse((value ?? '').trim());

                  if (number == null || number <= 0) {
                    return 'A whole number above 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _year,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  helperText: 'Optional',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                onTapOutside: _unfocus,
                validator: (value) {
                  final text = (value ?? '').trim();

                  if (text.isEmpty) return null;

                  final number = int.tryParse(text);
                  final currentYear = DateTime.now().year;

                  if (number == null || number < 1450 || number > currentYear) {
                    return 'Enter a year from 1450 to $currentYear';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
