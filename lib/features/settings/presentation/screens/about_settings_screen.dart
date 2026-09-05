import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About DelMess')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread,
                    size: AppDimensions.iconXl,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  AppStrings.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Version 1.0.0 (Build 1)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  AppStrings.appTagline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          const Divider(),
          ListTile(
            title: const Text('Open Source Licenses'),
            subtitle: const Text(
              'Third-party software notices and attributions',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: AppStrings.appName,
                applicationVersion: '1.0.0',
              );
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Architecture & Tech Stack'),
            subtitle: Text(
              'Built with Flutter, Material 3, Riverpod, and GoRouter.',
            ),
          ),
        ],
      ),
    );
  }
}
