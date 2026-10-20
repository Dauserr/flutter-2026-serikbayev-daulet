import 'package:flutter/material.dart';

import '../models/book.dart';
import '../utils/format.dart';

class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});
  final Book? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeFocus = FocusNode();
  late final Book _original;
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  Genre? _genre;
  DateTime? _date;
  TimeOfDay? _time;
  bool _online = false;
  bool _saving = false;
  late final String _initialSnapshot;

  @override
  void initState() {
    super.initState();
    _original = widget.book ?? Book.empty();
    _title = TextEditingController(text: _original.title);
    _place = TextEditingController(text: _original.place);
    _limit = TextEditingController(text: '${_original.limit}');
    _description = TextEditingController(text: _original.description ?? '');
    _genre = widget.book?.genre;
    _online = _original.online;
    if (widget.book != null) {
      _date = _original.when;
      _time = TimeOfDay.fromDateTime(_original.when);
    }
    _dateText = TextEditingController(
      text: _date == null ? '' : formatDate(_original.when),
    );
    _timeText = TextEditingController(
      text: _time == null ? '' : formatTime(_original.when),
    );
    _initialSnapshot = _snapshot;
    for (final controller in [_title, _place, _limit, _description]) {
      controller.addListener(_changed);
    }
  }

  String get _snapshot => [
    _title.text,
    _place.text,
    _limit.text,
    _description.text,
    _genre?.name,
    _date?.year,
    _date?.month,
    _date?.day,
    _time?.hour,
    _time?.minute,
    _online,
  ].map((value) => '$value').map((value) => '${value.length}:$value').join();

  bool get _dirty => _snapshot != _initialSnapshot;

  DateTime? get _meeting {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    for (final controller in [_title, _place, _limit, _description]) {
      controller.removeListener(_changed);
      controller.dispose();
    }
    _dateText.dispose();
    _timeText.dispose();
    _placeFocus.dispose();
    super.dispose();
  }

  void _unfocus(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? _original.when,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (date == null || mounted == false) return;
    setState(() {
      _date = date;
      _dateText.text = formatDate(date);
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.fromDateTime(_original.when),
    );
    if (time == null || mounted == false) return;
    setState(() {
      _time = time;
      _timeText.text =
          '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_formKey.currentState?.validate() != true) return;
    final when = _meeting;
    final genre = _genre;
    if (when == null || genre == null) return;

    setState(() => _saving = true);
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted == false) return;

    final description = _description.text.trim();
    final book = _original.copyWith(
      title: _title.text.trim(),
      place: _place.text.trim(),
      limit: int.parse(_limit.text.trim()),
      genre: genre,
      when: when,
      online: _online,
      description: description,
      clearDescription: description.isEmpty,
    );
    Navigator.of(context).pop(book);
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
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
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Book>(
      canPop: _dirty == false && _saving == false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _saving) return;
        await _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.book == null ? 'Add book' : 'Edit book'),
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
                  controller: _title,
                  enabled: _saving == false,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _unfocus,
                  validator: (value) {
                    final length = (value ?? '').trim().length;
                    return length < 3 || length > 60
                        ? 'Use 3 to 60 characters'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  enabled: _saving == false,
                  decoration: InputDecoration(
                    labelText: _online ? 'Meeting link' : 'Meeting place',
                  ),
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.streetAddress,
                  textInputAction: TextInputAction.next,
                  onTapOutside: _unfocus,
                  validator: (value) {
                    final place = (value ?? '').trim();
                    if (place.isEmpty) return 'Enter a meeting place';
                    if (_online && place.contains('://') == false) {
                      return 'Enter a link containing ://';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online discussion'),
                  value: _online,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _online = value ?? false),
                ),
                TextFormField(
                  controller: _limit,
                  enabled: _saving == false,
                  decoration: const InputDecoration(
                    labelText: 'Number of copies',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onTapOutside: _unfocus,
                  validator: (value) {
                    final number = int.tryParse((value ?? '').trim());
                    if (number == null || number < 1 || number > 500) {
                      return 'Enter a number from 1 to 500';
                    }
                    if (number < _original.count) {
                      return 'At least ${_original.count} copies are already borrowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Genre>(
                  initialValue: _genre,
                  decoration: const InputDecoration(labelText: 'Genre'),
                  items: [
                    for (final genre in Genre.values)
                      DropdownMenuItem(value: genre, child: Text(genre.label)),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _genre = value),
                  validator: (value) => value == null ? 'Choose a genre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateText,
                  readOnly: true,
                  enabled: _saving == false,
                  decoration: const InputDecoration(
                    labelText: 'Meeting date',
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: _pickDate,
                  onTapOutside: _unfocus,
                  validator: (_) {
                    final date = _date;
                    if (date == null) return 'Choose a date';
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    if (widget.book == null && date.isBefore(today)) {
                      return 'Choose today or a future date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timeText,
                  readOnly: true,
                  enabled: _saving == false,
                  decoration: const InputDecoration(
                    labelText: 'Meeting time',
                    suffixIcon: Icon(Icons.schedule),
                  ),
                  onTap: _pickTime,
                  onTapOutside: _unfocus,
                  validator: (_) {
                    if (_time == null) return 'Choose a time';
                    final when = _meeting;
                    if (widget.book == null &&
                        when != null &&
                        when.isAfter(DateTime.now()) == false) {
                      return 'The meeting must be in the future';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  enabled: _saving == false,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  onTapOutside: _unfocus,
                  validator: (_) => null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
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
