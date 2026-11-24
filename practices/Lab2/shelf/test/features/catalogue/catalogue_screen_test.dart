import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shelf/features/catalogue/catalogue_model.dart';
import 'package:shelf/features/catalogue/catalogue_screen.dart';
import 'package:shelf/features/catalogue/fake_book_repository.dart';
import 'package:shelf/features/shelf/fake_shelf_repository.dart';
import 'package:shelf/features/shelf/shelf_model.dart';

void main() {
  testWidgets('catalogue shows the offline error and Retry', (tester) async {
    final catalogue = CatalogueModel(
      FakeBookRepository(fail: true, delay: const Duration(milliseconds: 100)),
    );
    final shelf = ShelfModel(FakeShelfRepository());

    unawaited(catalogue.search('flutter'));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: catalogue),
          ChangeNotifierProvider.value(value: shelf),
        ],
        child: const MaterialApp(home: CatalogueScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    expect(find.text('No connection'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  });
}
