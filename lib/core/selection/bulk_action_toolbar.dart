import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/selection/bulk_action_handler.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkActionToolbar extends ConsumerWidget {
  final List<SmsConversation> allConversations;
  final bool isArchivedView;
  final bool isDeletedView;

  const BulkActionToolbar({
    super.key,
    required this.allConversations,
    this.isArchivedView = false,
    this.isDeletedView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionControllerProvider);
    if (!selectionState.isSelectionMode) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final selectedConversations = allConversations
        .where((c) => selectionState.isSelected(c.id))
        .toList();

    return Material(
      elevation: 8,
      color: theme.colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (isDeletedView) ...[
                Expanded(
                  child: _ActionItem(
                    icon: Icons.restore,
                    label: 'Restore',
                    onTap: () => BulkActionHandler.restoreSelected(
                      context,
                      ref,
                      selectedConversations,
                    ),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.delete_forever_outlined,
                    label: 'Delete Forever',
                    onTap: () => BulkActionHandler.deleteSelected(
                      context,
                      ref,
                      selectedConversations,
                    ),
                  ),
                ),
              ] else if (isArchivedView) ...[
                Expanded(
                  child: _ActionItem(
                    icon: Icons.unarchive_outlined,
                    label: 'Unarchive',
                    onTap: () => BulkActionHandler.unarchiveSelected(
                      context,
                      ref,
                      selectedConversations,
                    ),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    onTap: () => BulkActionHandler.deleteSelected(
                      context,
                      ref,
                      selectedConversations,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _ActionItem(
                    icon: Icons.mark_email_read_outlined,
                    label: 'Read',
                    onTap: () => BulkActionHandler.markReadSelected(
                      context,
                      ref,
                      selectedConversations,
                    ),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.archive_outlined,
                    label: 'Archive',
                    onTap: () => BulkActionHandler.archiveSelected(
                      context,
                      ref,
                      selectedConversations,
                    ),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.label_outline,
                    label: 'Label',
                    onTap: () => BulkActionHandler.showLabelDialog(
                      context,
                      ref,
                      selectedConversations,
                    ),
                  ),
                ),
                Expanded(
                  child: _ActionItem(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    onTap: () => BulkActionHandler.deleteSelected(
                      context,
                      ref,
                      selectedConversations,
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

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space4,
          vertical: AppDimensions.space8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: AppDimensions.space4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
