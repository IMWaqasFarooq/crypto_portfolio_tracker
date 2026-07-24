import 'package:flutter/material.dart';

import '../error/failures.dart';
import '../theme/app_spacing.dart';

/// Maps a [Failure] to a user-facing message, icon, and retry action.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.failure,
    this.onRetry,
  });

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(failure), size: 56, color: scheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              _titleFor(failure),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              failure.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(Failure failure) => switch (failure) {
        NetworkFailure() => Icons.wifi_off_rounded,
        UnauthorizedFailure() => Icons.lock_outline_rounded,
        ServerFailure() => Icons.cloud_off_rounded,
        CacheFailure() => Icons.storage_rounded,
        ValidationFailure() => Icons.error_outline_rounded,
        UnknownFailure() => Icons.error_outline_rounded,
      };

  String _titleFor(Failure failure) => switch (failure) {
        NetworkFailure() => 'No internet connection',
        UnauthorizedFailure() => 'Session expired',
        ServerFailure() => 'Something went wrong',
        CacheFailure() => 'Couldn\'t load local data',
        ValidationFailure() => 'Invalid input',
        UnknownFailure() => 'Unexpected error',
      };
}
