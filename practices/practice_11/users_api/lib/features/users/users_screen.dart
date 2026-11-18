import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
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

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UsersModel>();
    final Widget body;

    if (model.loading) {
      body = const LoadingView();
    } else {
      switch (model.error) {
        case null:
          body = model.items.isEmpty
              ? const Center(child: Text('No users'))
              : RefreshIndicator(
                  onRefresh: model.load,
                  child: UserList(
                    users: model.items,
                    onTap: (user) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => UserDetailScreen(user: user),
                        ),
                      );
                    },
                  ),
                );
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
      appBar: AppBar(title: const Text('Users')),
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
