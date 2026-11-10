import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _api = FakeApi();
  List<Student>? _students;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });

    try {
      final list = await _api.fetchStudents();

      if (!mounted) return;

      setState(() {
        _students = list;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e;
      });
    }
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await _api.save(_students!.length);

      if (!context.mounted) return;

      Navigator.of(context).pop();
    } on StateError catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;

    if (_error != null) {
      body = ErrorView(onRetry: _load);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(students: _students!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students by hand'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: _students == null
          ? null
          : FloatingActionButton(
              tooltip: 'Save',
              onPressed: _saving ? null : () => _save(context),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
      body: body,
    );
  }
}
