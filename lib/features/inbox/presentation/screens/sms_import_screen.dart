import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/widgets/app_buttons.dart';
import 'package:delmess/features/inbox/presentation/controllers/sms_permission_controller.dart';
import 'package:delmess/features/inbox/presentation/controllers/sms_sync_controller.dart';
import 'package:delmess/features/messages/data/sms_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying the initial batch import progress of SMS messages into the local database.
class SmsImportScreen extends ConsumerStatefulWidget {
  const SmsImportScreen({super.key});

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smsSyncControllerProvider.notifier).startInitialSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final syncProgress = ref.watch(smsSyncControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space32,
          ),
          child: Center(child: _buildContent(context, theme, syncProgress)),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    SmsSyncProgress progress,
  ) {
    switch (progress.status) {
      case SmsSyncStatus.completed:
        return _buildCompletedState(context, theme, progress);
      case SmsSyncStatus.error:
        return _buildErrorState(context, theme, progress);
      case SmsSyncStatus.inProgress:
      case SmsSyncStatus.idle:
        return _buildProgressState(context, theme, progress);
    }
  }

  Widget _buildProgressState(
    BuildContext context,
    ThemeData theme,
    SmsSyncProgress progress,
  ) {
    final fraction = progress.progressFraction;
    final total = progress.totalCount;
    final processed = progress.processedCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sync,
            size: AppDimensions.iconXl,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.space32),

        Text(
          'Organizing your messages',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space12),

        Text(
          total > 0
              ? '$processed of $total messages'
              : 'Reading messages from device...',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),

        // Progress indicator
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: total > 0
                ? LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  )
                : const LinearProgressIndicator(),
          ),
        ),
        const SizedBox(height: AppDimensions.space16),

        Text(
          'Building your inbox...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    ThemeData theme,
    SmsSyncProgress progress,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: AppDimensions.iconXl,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.space32),

        Text(
          'Your messages are ready',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space12),

        Text(
          progress.totalCount > 0
              ? 'Successfully organized ${progress.totalCount} messages.'
              : 'Inbox setup is complete.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space40),

        PrimaryButton(
          text: 'Open Inbox',
          width: double.infinity,
          icon: Icons.inbox,
          onPressed: () {
            context.go(RoutePaths.inbox);
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    SmsSyncProgress progress,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: AppDimensions.iconXl,
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: AppDimensions.space32),

        Text(
          "We couldn't import your messages",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space12),

        Text(
          progress.errorMessage ??
              'An error occurred during synchronization. Please ensure SMS permission is granted.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space40),

        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Open Settings',
                icon: Icons.settings,
                onPressed: () {
                  ref
                      .read(smsPermissionControllerProvider.notifier)
                      .openSettings();
                },
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: PrimaryButton(
                text: 'Try Again',
                icon: Icons.refresh,
                onPressed: () {
                  ref
                      .read(smsSyncControllerProvider.notifier)
                      .startInitialSync();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
