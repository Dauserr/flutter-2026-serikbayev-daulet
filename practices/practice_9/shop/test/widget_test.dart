import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shop/main.dart';
import 'package:shop/models/book.dart';
import 'package:shop/models/cart.dart';

Widget app() {
  return ChangeNotifierProvider(create: (_) => Cart(), child: const Shell());
}

void main() {
  group('Cart', () {
    test('counts distinct books and multiplies quantities', () {
      final cart = Cart();

      expect(cart.add(books[0]), isTrue);
      expect(cart.add(books[1]), isTrue);
      expect(cart.add(books[0]), isFalse);
      expect(cart.count, 2);
      expect(cart.total, 7300);

      cart.increment(books[0]);

      expect(cart.qtyOf(books[0]), 2);
      expect(cart.total, 11500);

      cart.remove(books[0]);

      expect(cart.count, 1);
      expect(cart.total, 3100);

      cart.clear();

      expect(cart.items, isEmpty);
      expect(cart.total, 0);
    });
  });

  testWidgets('adds books and opens the cart', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(ListTile), matching: find.text('Added')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('x1'), findsOneWidget);
    expect(find.text('4200 ₸'), findsOneWidget);

    await tester.tap(find.byTooltip('Add one'));
    await tester.pumpAndSettle();

    expect(find.text('x2'), findsOneWidget);
    expect(find.text('8400 ₸'), findsOneWidget);
  });

  testWidgets('filters books by title or author', (tester) async {
    await tester.pumpWidget(app());

    await tester.enterText(find.byType(TextField), 'null');
    await tester.pump();

    expect(find.text('Null Safety for Humans'), findsOneWidget);
    expect(find.text('Widgets All the Way Down'), findsNothing);

    await tester.enterText(find.byType(TextField), 'omarova');
    await tester.pump();

    expect(find.text('Forms That Validate Themselves'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsNothing);
  });

  testWidgets('clears the cart after confirmation', (tester) async {
    await tester.pumpWidget(app());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pumpAndSettle();

    expect(find.text('Clear cart?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('x1'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear cart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('Cart is empty'), findsOneWidget);
    expect(find.text('0 ₸'), findsOneWidget);
  });
}
