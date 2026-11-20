import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import 'generic_error_view.dart';
import 'offline_view.dart';
import 'server_error_view.dart';

class UsersErrorView extends StatelessWidget {
  const UsersErrorView({super.key, required this.error, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (error) {
      NoConnectionException() => OfflineView(onRetry: onRetry),
      NotFoundException() ||
      UnauthorizedException() => const GenericErrorView(),
      ServerException(:final status) => ServerErrorView(
        status: status,
        onRetry: onRetry,
      ),
      BadResponseException() => const GenericErrorView(),
    };
  }
}
