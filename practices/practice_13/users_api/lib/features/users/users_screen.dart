import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';
import 'widgets/empty_users_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/offline_banner.dart';
import 'widgets/user_list.dart';
import 'widgets/users_error_view.dart';
import 'widgets/users_filter_bar.dart';
import 'widgets/users_header.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Widget _list(BuildContext context, UsersModel model, String? city) {
    final items = city == null
        ? model.items
        : model.items.where((user) => user.address.city == city).toList();

    if (items.isEmpty) {
      return EmptyUsersView(city: city);
    }

    return RefreshIndicator(
      onRefresh: model.load,
      child: UserList(
        users: items,
        onTap: (user) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => UserDetailScreen(user: user),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final settings = context.watch<SettingsModel>();
    final error = model.error;
    final city = settings.city;

    Widget content;

    if (model.loading) {
      content = const LoadingView();
    } else if (error != null) {
      content = UsersErrorView(error: error, onRetry: model.load);
    } else {
      content = _list(context, model, city);

      if (model.fromCache) {
        content = Column(
          children: [
            OfflineBanner(onRetry: model.load),
            Expanded(child: content),
          ],
        );
      }
    }

    if (city != null && model.loading == false && error == null) {
      content = Column(
        children: [
          UsersFilterBar(
            city: city,
            onClear: () {
              unawaited(settings.setCity(null));
            },
          ),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      appBar: UsersHeader(
        onSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New user',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
          );
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: content,
    );
  }
}
