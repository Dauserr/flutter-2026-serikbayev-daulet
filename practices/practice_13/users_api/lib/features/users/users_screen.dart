import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';
import 'widgets/generic_error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/offline_view.dart';
import 'widgets/server_error_view.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Widget _cacheBanner(BuildContext context, UsersModel model) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.tertiaryContainer,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: colors.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saved data · no connection',
              style: TextStyle(color: colors.onTertiaryContainer),
            ),
          ),
          TextButton(onPressed: model.load, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, UsersModel model, String? city) {
    final items = city == null
        ? model.items
        : model.items.where((user) => user.address.city == city).toList();

    if (items.isEmpty) {
      return const Center(child: Text('No users'));
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
    final Widget body;

    if (model.loading) {
      body = const LoadingView();
    } else {
      switch (model.error) {
        case null:
          final content = _list(context, model, settings.city);

          body = model.fromCache
              ? Column(
                  children: [
                    _cacheBanner(context, model),
                    Expanded(child: content),
                  ],
                )
              : content;
        case NoConnectionException():
          body = OfflineView(onRetry: model.load);
        case NotFoundException() || UnauthorizedException():
          body = const GenericErrorView();
        case ServerException(:final status):
          body = ServerErrorView(status: status, onRetry: model.load);
        case BadResponseException():
          body = const GenericErrorView();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
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
      body: body,
    );
  }
}
