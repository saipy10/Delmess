import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/constants/app_strings.dart';
import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/theme/theme_provider.dart';
import 'package:delmess/features/inbox/presentation/controllers/inbox_controller.dart';
import 'package:delmess/features/labels/presentation/controllers/labels_controller.dart';
import 'package:delmess/features/labels/presentation/widgets/create_label_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App navigation drawer for DelMess inbox, categories, folders, labels, and shortcuts.
class InboxDrawer extends ConsumerWidget {
  const InboxDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final inboxState = ref.watch(inboxControllerProvider);
    final labelsState = ref.watch(labelsControllerProvider);
    final currentThemeMode = ref.watch(themeProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      color: theme.colorScheme.primary,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppStrings.appTagline,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      currentThemeMode == ThemeMode.dark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    tooltip: 'Toggle Theme',
                    onPressed: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
            const Divider(),

            // Scrollable Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: AppDimensions.space8,
                ),
                children: [
                  // Primary Inbox
                  ListTile(
                    leading: const Icon(Icons.all_inbox),
                    title: const Text('All Messages'),
                    trailing: Text(
                      '${inboxState.totalActiveCount}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    selected:
                        inboxState.currentFolder == InboxFolder.inbox &&
                        inboxState.selectedCategory == null,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    onTap: () {
                      ref
                          .read(inboxControllerProvider.notifier)
                          .setFolder(InboxFolder.inbox);
                      ref
                          .read(inboxControllerProvider.notifier)
                          .selectCategory(null);
                      context.pop();
                    },
                  ),

                  const SizedBox(height: AppDimensions.space8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                    ),
                    child: Text(
                      'CATEGORIES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),

                  // Category items
                  ...CategoryType.values.map((cat) {
                    final isSelected =
                        inboxState.currentFolder == InboxFolder.inbox &&
                        inboxState.selectedCategory == cat;
                    final count = inboxState.getCountForCategory(cat);
                    final accentColor = cat.getColor(context);

                    return ListTile(
                      dense: true,
                      leading: Icon(cat.icon, color: accentColor),
                      title: Text(cat.displayName),
                      trailing: Text('$count'),
                      selected: isSelected,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusMd,
                      ),
                      onTap: () {
                        ref
                            .read(inboxControllerProvider.notifier)
                            .setFolder(InboxFolder.inbox);
                        ref
                            .read(inboxControllerProvider.notifier)
                            .selectCategory(cat);
                        context.pop();
                      },
                    );
                  }),

                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                    ),
                    child: Text(
                      'FOLDERS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),

                  // Starred
                  ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.star_outline,
                      color: Colors.amber,
                    ),
                    title: const Text('Starred'),
                    trailing: Text('${inboxState.starredCount}'),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    onTap: () {
                      context.pop();
                      context.push(RoutePaths.starred);
                    },
                  ),

                  // Pinned
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.push_pin_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Pinned'),
                    trailing: Text('${inboxState.pinnedCount}'),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    onTap: () {
                      context.pop();
                      context.push(RoutePaths.pinned);
                    },
                  ),

                  // Archived
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.archive_outlined),
                    title: const Text('Archived'),
                    trailing: Text('${inboxState.archivedCount}'),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    onTap: () {
                      context.pop();
                      context.push(RoutePaths.archived);
                    },
                  ),

                  // Recently Deleted
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    title: const Text('Recently Deleted'),
                    trailing: Text('${inboxState.deletedCount}'),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusMd,
                    ),
                    onTap: () {
                      context.pop();
                      context.push(RoutePaths.deleted);
                    },
                  ),

                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space12,
                        ),
                        child: Text(
                          'LABELS',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => const CreateLabelSheet(),
                          );
                        },
                        icon: const Icon(Icons.add, size: AppDimensions.iconSm),
                        label: const Text('Create'),
                      ),
                    ],
                  ),

                  // Dynamic user labels
                  ...labelsState.labels.map((label) {
                    return ListTile(
                      dense: true,
                      leading: Icon(label.icon, color: label.color),
                      title: Text(label.name),
                      trailing: Text('${label.messageCount}'),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusMd,
                      ),
                      onTap: () {
                        context.pop();
                        context.push('/labels/${label.id}');
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
