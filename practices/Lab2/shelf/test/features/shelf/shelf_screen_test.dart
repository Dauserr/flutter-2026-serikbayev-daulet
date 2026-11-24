import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:shelf/features/settings/settings_model.dart';
import 'package:shelf/features/shelf/fake_shelf_repository.dart';
import 'package:shelf/features/shelf/shelf_model.dart';
import 'package:shelf/features/shelf/shelf_screen.dart';

class FakeSettingsModel extends SettingsModel {
  FakeSettingsModel()
    : super(SharedPreferencesAsync(), dark: false, defaultStatus: 'all');
}

void main() {
  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('shelf shows the offline error and Retry', (tester) async {
    final model = ShelfModel(
      FakeShelfRepository(fail: true, delay: const Duration(milliseconds: 100)),
    );

    unawaited(model.load());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: model),
          ChangeNotifierProvider<SettingsModel>.value(
            value: FakeSettingsModel(),
          ),
        ],
        child: const MaterialApp(home: ShelfScreen()),
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
