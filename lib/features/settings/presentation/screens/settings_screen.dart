import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/app_strings.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/features/settings/presentation/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main Settings Screen with the 6 dedicated sections.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
        children: [
          SettingsTile(
            icon: Icons.tune,
            iconColor: const Color(0xFF3F51B5),
            title: AppStrings.settingsGeneral,
            subtitle: 'Default SIM, backup, and language preferences',
            onTap: () => context.push(RoutePaths.settingsGeneral),
          ),
          const Divider(indent: 72),
          SettingsTile(
            icon: Icons.folder_special_outlined,
            iconColor: const Color(0xFF00897B),
            title: AppStrings.settingsOrganization,
            subtitle: 'Rules, OTP auto-cleanup, and custom filters',
            onTap: () => context.push(RoutePaths.settingsOrganization),
          ),
          const Divider(indent: 72),
          SettingsTile(
            icon: Icons.notifications_active_outlined,
            iconColor: const Color(0xFFE65100),
            title: AppStrings.settingsNotifications,
            subtitle: 'Instant alerts, OTP fast copy, and sounds',
            onTap: () => context.push(RoutePaths.settingsNotifications),
          ),
          const Divider(indent: 72),
          SettingsTile(
            icon: Icons.security_outlined,
            iconColor: const Color(0xFF1565C0),
            title: AppStrings.settingsPrivacy,
            subtitle: 'On-device machine learning, permissions, and security',
            onTap: () => context.push(RoutePaths.settingsPrivacy),
          ),
          const Divider(indent: 72),
          SettingsTile(
            icon: Icons.palette_outlined,
            iconColor: const Color(0xFF7B1FA2),
            title: AppStrings.settingsAppearance,
            subtitle: 'Light, dark, and system theme customization',
            onTap: () => context.push(RoutePaths.settingsAppearance),
          ),
          const Divider(indent: 72),
          SettingsTile(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF546E7A),
            title: AppStrings.settingsAbout,
            subtitle: 'App version, licenses, and contributor info',
            onTap: () => context.push(RoutePaths.settingsAbout),
          ),
        ],
      ),
    );
  }
}
