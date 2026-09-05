import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/category_constants.dart';
import 'package:flutter/material.dart';

/// Reusable Category Badge displaying Category Icon, Text Label, and subtle tinted Background.
/// Never relies solely on color to ensure accessibility and clarity.
class CategoryBadge extends StatelessWidget {
  final CategoryType category;
  final bool compact;
  final VoidCallback? onTap;

  const CategoryBadge({
    super.key,
    required this.category,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = category.getColor(context);
    final bgColor = category.getBackgroundColor(context);

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimensions.space6 : AppDimensions.space8,
        vertical: compact ? AppDimensions.space2 : AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppDimensions.borderRadiusSm,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: compact ? AppDimensions.iconXs : AppDimensions.iconSm,
            color: accentColor,
          ),
          SizedBox(
            width: compact ? AppDimensions.space4 : AppDimensions.space6,
          ),
          Text(
            category.displayName,
            style:
                (compact
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)
                    ?.copyWith(color: accentColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusSm,
        child: content,
      );
    }

    return content;
  }
}
