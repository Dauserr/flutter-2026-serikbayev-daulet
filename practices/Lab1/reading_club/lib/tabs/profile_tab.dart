import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.books,
    required this.themeMode,
    required this.onChanged,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<Book> books;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onChanged(
      Profile(name: _name.text.trim(), group: _group.text.trim()),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.books.fold<int>(0, (total, book) {
      return total +
          (widget.profile.name.isNotEmpty && book.contains(widget.profile.name)
              ? 1
              : 0);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _save(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (value) => (value ?? '').trim().length < 2
                  ? 'Enter at least 2 characters'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _group,
              decoration: const InputDecoration(
                labelText: 'Group',
                hintText: 'IT-2302',
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              validator: (value) =>
                  RegExp(r'^[A-Z]{2,4}-\d{4}$').hasMatch((value ?? '').trim())
                  ? null
                  : 'Use a group such as IT-2302',
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save profile')),
            const SizedBox(height: 24),
            Text('You are on $count lists'),
            const SizedBox(height: 24),
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in ThemeMode.values)
                  ChoiceChip(
                    label: Text(switch (mode) {
                      ThemeMode.system => 'System',
                      ThemeMode.light => 'Light',
                      ThemeMode.dark => 'Dark',
                    }),
                    selected: widget.themeMode == mode,
                    onSelected: (_) => widget.onThemeChanged(mode),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
