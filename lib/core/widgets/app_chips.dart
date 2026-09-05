import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

/// Reusable filter chip with active indicator state.
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final Color? activeColor;
  final Color? activeTextColor;
  final int unreadCount;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.icon,
    this.activeColor,
    this.activeTextColor,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isSelected
        ? (activeColor ?? theme.colorScheme.primaryContainer)
        : (isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ));

    final textColor = isSelected
        ? (activeTextColor ?? theme.colorScheme.onPrimaryContainer)
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected?.call(!isSelected),
        borderRadius: AppDimensions.borderRadiusFull,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: AppDimensions.space6,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppDimensions.borderRadiusFull,
            border: Border.all(
              color: isSelected
                  ? (activeColor ?? theme.colorScheme.primary).withValues(
                      alpha: 0.3,
                    )
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimensions.iconXs, color: textColor),
                const SizedBox(width: AppDimensions.space4),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: AppDimensions.space6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? textColor : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: TextStyle(
                      color: isSelected ? bgColor : theme.colorScheme.onPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
