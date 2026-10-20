import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.arguments});
  final DetailArguments arguments;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Book _book = widget.arguments.book;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _change(Book book) {
    widget.arguments.onChanged(book);
    setState(() => _book = book);
  }

  Future<void> _edit() async {
    final book = await Navigator.of(context)
        .pushNamed<Book>(Routes.form, arguments: FormArguments(book: _book));
    if (book == null || mounted == false) return;
    _change(book);
  }

  Future<bool> _ask(String title, String action) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return answer == true;
  }

  Future<void> _delete() async {
    final confirmed = await _ask('Delete ${_book.title}?', 'Delete');
    if (confirmed == false || mounted == false) return;
    widget.arguments.onDeleted(_book.id);
    Navigator.of(context).pop();
  }

  Future<void> _borrow() async {
    final name = widget.arguments.profile.name;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Save your profile before borrowing.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              if (mounted == false) return;
              widget.arguments.onProfileRequested();
              Navigator.of(context).pop();
            },
          ),
        ),
      );
      return;
    }

    if (_book.contains(name)) {
      _change(
        _book.copyWith(
          readers: _book.readers.where((reader) => reader != name).toList(),
        ),
      );
      return;
    }

    final confirmed = await _ask('Borrow ${_book.title}?', 'Borrow');
    if (confirmed == false || mounted == false) return;
    if (_book.isFull || _book.contains(name)) return;
    _change(_book.copyWith(readers: [..._book.readers, name]));
  }

  Widget _header() {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/reading_header.png', fit: BoxFit.cover),
        Center(
          child: CircleAvatar(
            backgroundColor: _book.genre.color(colors),
            child: Icon(_book.genre.icon, color: colors.onSurface),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Chip(label: Text(_book.genre.label, style: text.labelLarge)),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Chip(
            label: Text(
              formatCountdown(_book.countdown),
              style: text.labelLarge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _about() {
    final (:taken, :free) = _book.places;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_book.title, style: Theme.of(context).textTheme.headlineSmall),
        ListTile(
          title: const Text('Meeting'),
          subtitle: Text(formatDateTime(_book.when)),
        ),
        ListTile(
          title: Text(_book.online ? 'Meeting link' : 'Meeting place'),
          subtitle: Text(_book.place),
        ),
        ListTile(
          title: const Text('Copies'),
          subtitle: Text(
            '$taken borrowed · $free available · ${_book.limit} total',
          ),
        ),
        if (_book.description case final description?)
          Padding(padding: const EdgeInsets.all(16), child: Text(description)),
      ],
    );
  }

  Widget _readers() {
    if (_book.readers.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has borrowed this book yet',
      );
    }
    final colors = Theme.of(context).colorScheme;
    final name = widget.arguments.profile.name;
    return ListView.builder(
      itemCount: _book.count,
      itemBuilder: (context, index) {
        final reader = _book.readers[index];
        final isYou = reader == name;
        return ListTile(
          tileColor: isYou ? colors.primaryContainer : null,
          title: Text(reader),
          trailing: isYou ? const Text('You') : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final borrowed = _book.contains(widget.arguments.profile.name);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _edit();
                } else {
                  _delete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(flex: 2, child: _header()),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Borrowers (${_book.count})'),
              ],
            ),
            Expanded(
              flex: 3,
              child: TabBarView(children: [_about(), _readers()]),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _book.isFull && borrowed == false ? null : _borrow,
              child: Text(borrowed ? 'Return book' : 'Borrow'),
            ),
          ),
        ),
      ),
    );
  }
}
