import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:users_api/features/settings/settings_model.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/users_screen.dart';

import '../../fakes/fake_user_repository.dart';

class FakeSettingsModel extends SettingsModel {
  FakeSettingsModel() : super(SharedPreferencesAsync(), dark: false);
}

void main() {
  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('shows the offline view and Retry', (tester) async {
    final model = UsersModel(
      FakeUserRepository(fail: true, delay: const Duration(milliseconds: 100)),
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
        child: const MaterialApp(home: UsersScreen()),
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
