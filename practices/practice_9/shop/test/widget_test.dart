import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop/main.dart';

void main() {
  testWidgets('adds a book to the cart', (tester) async {
    await tester.pumpWidget(const Shell());

    expect(find.text('0 · 0 ₸'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();

    expect(find.text('1 · 4200 ₸'), findsOneWidget);
    expect(find.text('Added'), findsOneWidget);
  });
}
