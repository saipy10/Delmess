import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Reusable settings list tile component.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.space8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppDimensions.borderRadiusMd,
        ),
        child: Icon(icon, color: color, size: AppDimensions.iconSm + 2),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.outlineVariant,
            size: AppDimensions.iconSm,
          ),
      onTap: onTap,
    );
  }
}
