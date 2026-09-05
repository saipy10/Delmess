import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/core/widgets/app_buttons.dart';
import 'package:delmess/features/inbox/presentation/controllers/sms_permission_controller.dart';
import 'package:delmess/features/onboarding/presentation/widgets/feature_bullet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SMS Permission Explanation screen educating the user and requesting runtime SMS access.
class PermissionExplanationScreen extends ConsumerWidget {
  const PermissionExplanationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final permState = ref.watch(smsPermissionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SMS Access')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shield icon
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color:
                              permState == SmsPermissionState.denied ||
                                  permState ==
                                      SmsPermissionState.permanentlyDenied
                              ? theme.colorScheme.errorContainer
                              : theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          permState == SmsPermissionState.denied ||
                                  permState ==
                                      SmsPermissionState.permanentlyDenied
                              ? Icons.sms_failed_outlined
                              : Icons.verified_user_outlined,
                          size: AppDimensions.iconXl,
                          color:
                              permState == SmsPermissionState.denied ||
                                  permState ==
                                      SmsPermissionState.permanentlyDenied
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),

                      Text(
                        permState == SmsPermissionState.denied ||
                                permState ==
                                    SmsPermissionState.permanentlyDenied
                            ? 'SMS access is required'
                            : 'SMS Access',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Text(
                        permState == SmsPermissionState.denied ||
                                permState ==
                                    SmsPermissionState.permanentlyDenied
                            ? 'Without SMS access, SMS Organizer cannot import or organize your messages.'
                            : 'SMS Organizer needs access to your SMS messages to organize them into categories, labels and searchable lists.\n\nYour messages are processed locally on device according to its privacy design.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space32),

                      // Permissions breakdown
                      const FeatureBullet(
                        icon: Icons.sms_outlined,
                        title: 'Read SMS',
                        description:
                            'Allows DelMess to organize your incoming messages into clean threads.',
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      const FeatureBullet(
                        icon: Icons.cloud_off_outlined,
                        title: 'No Network Upload',
                        description:
                            'Your personal conversations, bank alerts, and messages never leave your phone.',
                      ),
                      const SizedBox(height: AppDimensions.space20),
                      const FeatureBullet(
                        icon: Icons.lock_outline,
                        title: 'Private & Local',
                        description:
                            'DelMess works completely offline with no cloud accounts or analytics tracking.',
                      ),
                      const SizedBox(height: AppDimensions.space24),
                    ],
                  ),
                ),
              ),

              // Action buttons based on permission state
              if (permState == SmsPermissionState.permanentlyDenied) ...[
                PrimaryButton(
                  text: 'Open Settings',
                  width: double.infinity,
                  icon: Icons.settings,
                  onPressed: () {
                    ref
                        .read(smsPermissionControllerProvider.notifier)
                        .openSettings();
                  },
                ),
              ] else if (permState == SmsPermissionState.denied) ...[
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
                        onPressed: () async {
                          final res = await ref
                              .read(smsPermissionControllerProvider.notifier)
                              .requestPermission();
                          if (res == SmsPermissionState.granted &&
                              context.mounted) {
                            context.go(RoutePaths.import);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                PrimaryButton(
                  text: 'Allow SMS Access',
                  width: double.infinity,
                  icon: Icons.lock_open,
                  onPressed: () async {
                    final res = await ref
                        .read(smsPermissionControllerProvider.notifier)
                        .requestPermission();
                    if (res == SmsPermissionState.granted && context.mounted) {
                      context.go(RoutePaths.import);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
