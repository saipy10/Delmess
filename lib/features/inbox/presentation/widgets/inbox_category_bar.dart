import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/widgets/app_chips.dart';
import 'package:delmess/features/inbox/presentation/controllers/inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Horizontal scrollable category bar for instant SMS classification filtering.
class InboxCategoryBar extends ConsumerWidget {
  const InboxCategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxState = ref.watch(inboxControllerProvider);
    final selectedCategory = inboxState.selectedCategory;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
        children: [
          // "All" filter chip
          AppFilterChip(
            label: 'All (${inboxState.totalActiveCount})',
            isSelected: selectedCategory == null,
            icon: Icons.all_inbox,
            unreadCount: inboxState.folderCounts.unreadInbox,
            onSelected: (_) {
              ref.read(inboxControllerProvider.notifier).selectCategory(null);
            },
          ),
          const SizedBox(width: AppDimensions.space8),

          // Categorized chips
          ...CategoryType.values.map((category) {
            final isSelected = selectedCategory == category;
            final count = inboxState.getCountForCategory(category);
            final unreadCount = inboxState.getUnreadCountForCategory(category);
            final accentColor = category.getColor(context);
            final bgColor = category.getBackgroundColor(context);

            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.space8),
              child: AppFilterChip(
                label: '${category.displayName} ($count)',
                isSelected: isSelected,
                icon: category.icon,
                activeColor: bgColor,
                activeTextColor: accentColor,
                unreadCount: unreadCount,
                onSelected: (_) {
                  ref
                      .read(inboxControllerProvider.notifier)
                      .selectCategory(isSelected ? null : category);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
