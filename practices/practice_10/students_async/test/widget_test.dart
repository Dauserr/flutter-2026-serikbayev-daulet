import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:students_async/api/fake_api.dart';
import 'package:students_async/main.dart';

Future<void> open(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('fake API fails every third fetch', (tester) async {
    final api = FakeApi();

    for (var call = 1; call <= 3; call++) {
      Object? failure;
      final future = api.fetchStudents().catchError((Object error) {
        failure = error;
        return const <Student>[];
      });

      await tester.pump(const Duration(seconds: 2));

      final students = await future;

      if (call == 3) {
        expect(failure, isA<NoConnectionException>());
        expect(students, isEmpty);
      } else {
        expect(failure, isNull);
        expect(students, hasLength(6));
      }
    }
  });

  testWidgets('fake API rejects every second save', (tester) async {
    final api = FakeApi();

    final first = api.save(6);
    await tester.pump(const Duration(seconds: 1));
    await first;

    final second = api.save(6);
    final expectation = expectLater(
      second,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'server rejected 6',
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    await expectation;
  });

  testWidgets('by hand loads students', (tester) async {
    await tester.pumpWidget(const MyApp());
    await open(tester, 'By hand');

    expect(find.text('Loading students.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('Dana Omarova'), findsOneWidget);
    expect(find.text('3.7'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('by hand reaches the error on the third load and retries', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await open(tester, 'By hand');

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    await tester.tap(find.byTooltip('Reload'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Aida Nurlanova'), findsOneWidget);

    await tester.tap(find.byTooltip('Reload'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Could not load students'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Aida Nurlanova'), findsOneWidget);
  });

  testWidgets('FutureBuilder keeps its Future when compact changes', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await open(tester, 'FutureBuilder');

    expect(find.text('Loading students.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Aida Nurlanova'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(find.text('Loading students.'), findsNothing);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
  });
}
