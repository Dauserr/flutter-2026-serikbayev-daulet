import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:warmup_1_counter/main.dart';

void main() {
  testWidgets('counter is shared between screens', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CounterModel(),
        child: const CounterApp(),
      ),
    );

    await tester.tap(find.text('+1'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Second screen'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('+1'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });
}
