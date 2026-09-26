import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/core/widgets/app_buttons.dart';
import 'package:delmess/features/inbox/presentation/controllers/sms_permission_controller.dart';
import 'package:delmess/features/onboarding/presentation/widgets/feature_bullet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SMS Permission Explanation & Prominent Disclosure Screen.
/// Fully adheres to Google Play prominent disclosure and user consent policies.
class PermissionExplanationScreen extends ConsumerWidget {
  const PermissionExplanationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final permState = ref.watch(smsPermissionControllerProvider);
    final isDenied = permState == SmsPermissionState.denied;
    final isPermanentlyDenied = permState == SmsPermissionState.permanentlyDenied;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Access'),
        actions: [
          if (!isPermanentlyDenied)
            TextButton(
              onPressed: () => _handleDecline(context),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status / Shield Icon with Container
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.space16),
                          decoration: BoxDecoration(
                            color: isDenied || isPermanentlyDenied
                                ? theme.colorScheme.errorContainer
                                : theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDenied || isPermanentlyDenied
                                ? Icons.sms_failed_outlined
                                : Icons.verified_user_outlined,
                            size: AppDimensions.iconXl,
                            color: isDenied || isPermanentlyDenied
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // Prominent Privacy Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.space12,
                            vertical: AppDimensions.space4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.12),
                            borderRadius: AppDimensions.borderRadiusFull,
                            border: Border.all(
                              color: Colors.teal.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '100% On-Device • Zero Network Upload',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space20),

                      // Primary Title
                      Text(
                        isDenied || isPermanentlyDenied
                            ? 'SMS access is required'
                            : 'SMS Access',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),

                      // Contextual Explanation Paragraph
                      Text(
                        isPermanentlyDenied
                            ? 'Without SMS access, DelMess cannot organize or display your messages. Because "Don\'t ask again" was selected, Android requires manual activation in System Settings.'
                            : isDenied
                            ? 'Without SMS access, SMS Organizer cannot import or organize your messages. DelMess operates completely locally on your phone without cloud servers.'
                            : 'DelMess is an offline-first SMS organizer. To sort and protect your messages, DelMess requires the following permissions before proceeding:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),

                      // Prominent Disclosure Detail Cards
                      const FeatureBullet(
                        icon: Icons.mark_email_read_outlined,
                        title: 'Read SMS (android.permission.READ_SMS)',
                        description:
                            'Enables DelMess to read and index existing messages on your physical phone into Transactional, Service, Promotional, and Government feeds.',
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      const FeatureBullet(
                        icon: Icons.notification_important_outlined,
                        title: 'Receive SMS (android.permission.RECEIVE_SMS)',
                        description:
                            'Enables DelMess to identify incoming SMS in real-time, instantly categorize new notifications, and extract OTP codes for one-tap clipboard copying.',
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      const FeatureBullet(
                        icon: Icons.memory_outlined,
                        title: '100% Local On-Device Processing',
                        description:
                            'All TRAI commercial header decoding (e.g. AX-HDFCBK), regex pattern matching, and heuristics are executed locally via client-side Dart and SQLite.',
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      const FeatureBullet(
                        icon: Icons.cloud_off_outlined,
                        title: 'No Network Upload',
                        description:
                            'Release builds contain zero internet permissions (android.permission.INTERNET is completely absent). Your messages never leave your phone.',
                      ),
                      const SizedBox(height: AppDimensions.space20),

                      // Privacy Policy Link
                      InkWell(
                        onTap: () => _showPolicyDialog(context),
                        borderRadius: AppDimensions.borderRadiusSm,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.privacy_tip_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'View Public Privacy Policy & Data Disclosures',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // Action buttons based on permission state
              if (isPermanentlyDenied) ...[
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
                const SizedBox(height: AppDimensions.space8),
                AppOutlinedButton(
                  text: 'Continue Without SMS',
                  width: double.infinity,
                  icon: Icons.arrow_forward,
                  onPressed: () => _handleDecline(context),
                ),
              ] else if (isDenied) ...[
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
                        onPressed: () => _requestPermission(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Center(
                  child: TextButton(
                    onPressed: () => _handleDecline(context),
                    child: const Text('Continue Without SMS'),
                  ),
                ),
              ] else ...[
                PrimaryButton(
                  text: 'Allow SMS Access',
                  width: double.infinity,
                  icon: Icons.lock_open,
                  onPressed: () => _requestPermission(context, ref),
                ),
                const SizedBox(height: AppDimensions.space8),
                AppOutlinedButton(
                  text: 'Not Now',
                  width: double.infinity,
                  icon: Icons.close,
                  onPressed: () => _handleDecline(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context, WidgetRef ref) async {
    final res = await ref
        .read(smsPermissionControllerProvider.notifier)
        .requestPermission();
    if (res == SmsPermissionState.granted && context.mounted) {
      context.go(RoutePaths.import);
    }
  }

  void _handleDecline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'SMS access declined. You can enable SMS permissions anytime in Settings.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.go(RoutePaths.inbox);
  }

  void _showPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.teal),
            SizedBox(width: 8),
            Text('DelMess Privacy Policy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '100% On-Device SMS Organizer\n'
                'Support: c7122867@gmail.com\n'
                'Hosted URL: https://saipy10.github.io/Delmess/privacy_policy.html\n\n'
                '• Zero Cloud Upload: Production release contains 0 internet permission.\n'
                '• READ_SMS: Reads existing SMS messages to sort into Transactional, Service, Promo, Govt.\n'
                '• RECEIVE_SMS: Detects incoming SMS in real-time to sort and display OTP chips.\n'
                '• Ephemeral OTPs: Verification codes are extracted dynamically in RAM and never stored to disk.\n'
                '• Sandboxed Storage: SQLite database is isolated inside Android UID sandbox.\n'
                '• User Control: Delete messages or clear all local data at any time.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(
                  text: 'https://saipy10.github.io/Delmess/privacy_policy.html',
                ),
              );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy URL copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Copy URL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
