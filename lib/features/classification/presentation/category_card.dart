import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/widgets/app_cards.dart';
import 'package:flutter/material.dart';

/// Reusable Category Card component highlighting Category Icon, Name, Description, and Message Count.
class CategoryCard extends StatelessWidget {
  final CategoryType category;
  final int count;
  final int unreadCount;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.count = 0,
    this.unreadCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = category.getColor(context);
    final bgColor = category.getBackgroundColor(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppDimensions.borderRadiusMd,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              category.icon,
              color: accentColor,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: AppDimensions.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space6,
                          vertical: AppDimensions.space2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: AppDimensions.borderRadiusFull,
                        ),
                        child: Text(
                          '$unreadCount new',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  category.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
                size: AppDimensions.iconSm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
