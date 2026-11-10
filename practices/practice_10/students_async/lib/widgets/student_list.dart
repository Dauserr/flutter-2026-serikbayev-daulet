import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class StudentList extends StatelessWidget {
  const StudentList({super.key, required this.students, this.compact = false});

  final List<Student> students;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final initial = student.name.isEmpty ? '?' : student.name[0];

        return ListTile(
          dense: compact,
          leading: CircleAvatar(child: Text(initial)),
          title: Text(student.name),
          subtitle: Text(student.group),
          trailing: Text(student.gpa?.toStringAsFixed(1) ?? '-'),
        );
      },
    );
  }
}
