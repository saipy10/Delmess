import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/inbox/presentation/controllers/sms_permission_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final permService = ref.watch(smsPermissionServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.shield_outlined, color: Colors.teal),
            title: Text('Zero Cloud Upload Guarantee'),
            subtitle: Text(
              'DelMess operates 100% locally on your device. Release builds contain zero internet permission.',
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.key_off_outlined, color: Colors.indigo),
            title: Text('Ephemeral OTP Processing'),
            subtitle: Text(
              'OTPs and verification codes are extracted dynamically in-memory and are NEVER persisted into the SQLite database.',
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.analytics_outlined, color: Colors.blue),
            title: Text('No Usage Telemetry or Ads'),
            subtitle: Text(
              'No third-party trackers, Google Analytics, Firebase, Facebook SDK, or ad networks.',
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              ref.watch(smsPermissionControllerProvider) == SmsPermissionState.granted
                  ? Icons.check_circle_outlined
                  : Icons.warning_amber_outlined,
              color: ref.watch(smsPermissionControllerProvider) == SmsPermissionState.granted
                  ? Colors.green
                  : Colors.amber,
            ),
            title: const Text('SMS Permissions (READ_SMS & RECEIVE_SMS)'),
            subtitle: Text(
              ref.watch(smsPermissionControllerProvider) == SmsPermissionState.granted
                  ? 'Access granted (100% on-device processing)'
                  : ref.watch(smsPermissionControllerProvider) ==
                          SmsPermissionState.permanentlyDenied
                      ? 'Permanently denied — tap to open System Settings'
                      : 'Denied or not granted — tap to review disclosure',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final state = ref.read(smsPermissionControllerProvider);
              if (state == SmsPermissionState.permanentlyDenied) {
                ref.read(smsPermissionControllerProvider.notifier).openSettings();
              } else {
                context.push(RoutePaths.permissions);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.mark_email_read_outlined, color: Colors.purple),
            title: const Text('Default SMS Handler Status'),
            subtitle: const Text(
              'Check or set DelMess as your default SMS handler for enhanced reliability and Play Store compliance',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final isDefault = await permService.isDefaultSmsApp();
              if (context.mounted) {
                if (isDefault) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('DelMess is currently set as your default SMS app!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  final result = await permService.requestDefaultSmsApp();
                  if (context.mounted && result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('DelMess set as default SMS app!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.policy_outlined, color: Colors.green),
            title: const Text('DelMess Privacy Policy'),
            subtitle: const Text(
              'Read our complete public privacy disclosures, on-device guarantees, and developer contact',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicyDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.link_outlined, color: Colors.blue),
            title: const Text('Public Hosted Policy URL'),
            subtitle: const Text(
              'https://saipy10.github.io/Delmess/privacy_policy.html',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.copy_outlined, size: 20),
              tooltip: 'Copy Policy Link',
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(
                    text: 'https://saipy10.github.io/Delmess/privacy_policy.html',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy URL copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('Delete All Local Data & Cache'),
            subtitle: const Text(
              'Permanently erase all locally indexed messages, classifications, and custom tags',
            ),
            onTap: () => _confirmClearData(context, ref),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Support Email: c7122867@gmail.com\nSandboxed in private internal app storage.\nRelease build: 0 internet permissions.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
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
                'Effective Date: September 2026\n'
                'Application: DelMess (Smart SMS Organizer)\n'
                'Package: com.delmess.smsorganizer.delmess\n'
                'Support: c7122867@gmail.com\n'
                'Public URL: https://saipy10.github.io/Delmess/privacy_policy.html\n\n'
                '1. 100% On-Device Architecture\n'
                'DelMess is strictly offline-first. Production release builds contain NO android.permission.INTERNET. '
                'Messages, OTPs, financial details, and sender information cannot be transmitted over the internet.\n\n'
                '2. SMS Processing & Header Decoding\n'
                'DelMess analyzes SMS messages exclusively on your phone to sort them into Transactional, Service, '
                'Promotional, Government, and Other feeds. It decodes TRAI sender headers (e.g. AX-HDFCBK) using local heuristics.\n\n'
                '3. Ephemeral OTP Intelligence\n'
                'Verification codes (OTPs) are extracted in-memory on-the-fly for convenient one-tap copying. DelMess NEVER persists OTPs into its SQLite database on disk.\n\n'
                '4. Sandboxed Local Storage\n'
                'Message metadata and custom tags are stored locally in a private SQLite database inside Android\'s secure app sandbox. Other apps cannot access DelMess data.\n\n'
                '5. Android Permissions\n'
                '• READ_SMS: Index & sort SMS on-device.\n'
                '• RECEIVE_SMS: Real-time SMS categorization & OTP extraction.\n'
                '• SEND_SMS: Send text messages when DelMess is Default SMS App.\n'
                '• RECEIVE_MMS / RECEIVE_WAP_PUSH: Default SMS App requirements.\n'
                'DelMess requests ZERO location, contacts, camera, mic, or storage permissions.\n\n'
                '6. Third-Party Libraries & Zero Telemetry\n'
                '• No Google Analytics, Firebase, Mixpanel, or Facebook SDK.\n'
                '• No advertising networks (100% ad-free).\n'
                '• No remote crash reporting (Sentry/Crashlytics). System stack traces remain strictly within local Android logcat.\n\n'
                '7. Data Deletion & Full Control\n'
                'Delete single messages, clear the trash, wipe all app data in Settings > Privacy & Security, '
                'or uninstall the app to instantly delete all data permanently.\n\n'
                'Contact: c7122867@gmail.com',
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy URL'),
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
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erase All Local Data?'),
        content: const Text(
          'This will permanently delete all categorized messages, tags, and local inbox state from DelMess storage. Real SMS messages on your phone will remain untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final db = ref.read(appDatabaseProvider);
              await db.transaction(() async {
                await db.delete(db.messageLabels).go();
                await db.delete(db.messages).go();
                await db.delete(db.labels).go();
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All local app data cleared successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Erase Everything'),
          ),
        ],
      ),
    );
  }
}
