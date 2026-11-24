import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../catalogue/book.dart';
import 'shelf_entry.dart';
import 'shelf_model.dart';

class ShelfFormScreen extends StatefulWidget {
  const ShelfFormScreen({super.key, this.entry, this.book});

  final ShelfEntry? entry;
  final Book? book;

  @override
  State<ShelfFormScreen> createState() => _ShelfFormScreenState();
}

class _ShelfFormScreenState extends State<ShelfFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pages = TextEditingController();
  final _notes = TextEditingController();
  final _date = TextEditingController();

  late String _status;
  late double? _rating;
  late DateTime _targetDate;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _status = entry?.status ?? 'want';
    _rating = entry?.rating;
    _targetDate =
        entry?.targetDate ?? DateTime.now().add(const Duration(days: 7));
    _pages.text = '${entry?.pagesRead ?? 0}';
    _notes.text = entry?.notes ?? '';
    _date.text = _targetDate.toLocal().toString().split(' ').first;
  }

  @override
  void dispose() {
    _pages.dispose();
    _notes.dispose();
    _date.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_dirty) return;
    setState(() {
      _dirty = true;
    });
  }

  String _message(ApiException error) {
    return switch (error) {
      NoConnectionException() => 'No connection',
      NotFoundException() => 'Entry not found',
      UnauthorizedException() => 'Session expired',
      ServerException(:final status) => 'Server error $status',
      BadResponseException(:final detail) =>
        detail ?? 'Could not save the entry',
    };
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    setState(() {
      _targetDate = date;
      _date.text = date.toLocal().toString().split(' ').first;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_formKey.currentState!.validate() == false) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _saving = true;
    });

    final book = widget.book;
    final entry = widget.entry;
    final title = entry?.title ?? book?.title ?? 'Unknown book';
    final authors =
        entry?.authors ??
        book?.authors.map((author) => author.name).join(', ') ??
        'Unknown author';
    final bookKey = entry?.bookKey ?? book?.key ?? '';

    final draft = ShelfEntry(
      id: entry?.id,
      bookKey: bookKey,
      title: title,
      authors: authors,
      status: _status,
      rating: _rating,
      pagesRead: int.parse(_pages.text.trim()),
      notes: _notes.text.trim(),
      targetDate: _targetDate,
      finished: _status == 'read',
    );

    final error = await context.read<ShelfModel>().save(draft);

    if (!mounted) return;

    setState(() {
      _saving = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_message(error))));
      return;
    }

    setState(() {
      _dirty = false;
    });

    Navigator.of(context).pop(true);
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('The form has unsaved changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (discard != true || !mounted) return;

    setState(() {
      _dirty = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.entry?.title ?? widget.book?.title ?? 'Book';

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _saving) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.entry == null ? 'Add to shelf' : 'Edit entry'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: title,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Book'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'want',
                      child: Text('Want to read'),
                    ),
                    DropdownMenuItem(value: 'reading', child: Text('Reading')),
                    DropdownMenuItem(value: 'read', child: Text('Read')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _status = value;
                      _dirty = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _rating?.toStringAsFixed(0) ?? 'none',
                  decoration: const InputDecoration(labelText: 'Rating'),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('Not rated')),
                    DropdownMenuItem(value: '1', child: Text('1')),
                    DropdownMenuItem(value: '2', child: Text('2')),
                    DropdownMenuItem(value: '3', child: Text('3')),
                    DropdownMenuItem(value: '4', child: Text('4')),
                    DropdownMenuItem(value: '5', child: Text('5')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _rating = value == null || value == 'none'
                          ? null
                          : double.parse(value);
                      _dirty = true;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pages,
                  decoration: const InputDecoration(labelText: 'Pages read'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markDirty(),
                  validator: (value) {
                    final pages = int.tryParse((value ?? '').trim());

                    if (pages == null || pages < 0) {
                      return 'Enter a whole number of pages';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                  onChanged: (_) => _markDirty(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  controller: _date,
                  decoration: const InputDecoration(
                    labelText: 'Target date',
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
