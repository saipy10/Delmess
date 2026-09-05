import 'package:delmess/core/selection/bulk_action_handler.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final List<SmsConversation> allConversations;
  final bool isArchivedView;
  final bool isDeletedView;

  const SelectionAppBar({
    super.key,
    required this.allConversations,
    this.isArchivedView = false,
    this.isDeletedView = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectionState = ref.watch(selectionControllerProvider);
    final selectedCount = selectionState.selectedCount;
    final allIds = allConversations.map((c) => c.id).toList();
    final isAllSelected =
        allConversations.isNotEmpty && selectedCount == allConversations.length;

    final selectedConversations = allConversations
        .where((c) => selectionState.isSelected(c.id))
        .toList();

    // Determine state of selected items
    final allAreStarred =
        selectedConversations.isNotEmpty &&
        selectedConversations.every((c) => c.isStarred);
    final allArePinned =
        selectedConversations.isNotEmpty &&
        selectedConversations.every((c) => c.isPinned);
    final allAreRead =
        selectedConversations.isNotEmpty &&
        selectedConversations.every((c) => !c.hasUnread);

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Exit selection',
        onPressed: () {
          ref.read(selectionControllerProvider.notifier).exitSelection();
        },
      ),
      title: Text(
        '$selectedCount selected',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: [
        // Select All / Deselect All toggle
        IconButton(
          icon: Icon(
            isAllSelected ? Icons.deselect_outlined : Icons.select_all_outlined,
          ),
          tooltip: isAllSelected ? 'Deselect All' : 'Select All',
          onPressed: () {
            if (isAllSelected) {
              ref.read(selectionControllerProvider.notifier).clearSelection();
            } else {
              ref.read(selectionControllerProvider.notifier).selectAll(allIds);
            }
          },
        ),

        // If in deleted view, show Restore and Permanent Delete
        if (isDeletedView) ...[
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restore',
            onPressed: () => BulkActionHandler.restoreSelected(
              context,
              ref,
              selectedConversations,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: 'Delete Forever',
            onPressed: () => BulkActionHandler.deleteSelected(
              context,
              ref,
              selectedConversations,
            ),
          ),
        ] else if (isArchivedView) ...[
          IconButton(
            icon: const Icon(Icons.unarchive_outlined),
            tooltip: 'Unarchive',
            onPressed: () => BulkActionHandler.unarchiveSelected(
              context,
              ref,
              selectedConversations,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => BulkActionHandler.deleteSelected(
              context,
              ref,
              selectedConversations,
            ),
          ),
        ] else ...[
          // Normal Inbox & Categories view: Keep top actions clean & responsive
          // Archive
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archive',
            onPressed: () => BulkActionHandler.archiveSelected(
              context,
              ref,
              selectedConversations,
            ),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => BulkActionHandler.deleteSelected(
              context,
              ref,
              selectedConversations,
            ),
          ),
        ],

        // More options dropdown for secondary actions
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (val) {
            if (val == 'label') {
              BulkActionHandler.showLabelDialog(
                context,
                ref,
                selectedConversations,
              );
            } else if (val == 'star') {
              if (allAreStarred) {
                BulkActionHandler.unstarSelected(
                  context,
                  ref,
                  selectedConversations,
                );
              } else {
                BulkActionHandler.starSelected(
                  context,
                  ref,
                  selectedConversations,
                );
              }
            } else if (val == 'read') {
              if (allAreRead) {
                BulkActionHandler.markUnreadSelected(
                  context,
                  ref,
                  selectedConversations,
                );
              } else {
                BulkActionHandler.markReadSelected(
                  context,
                  ref,
                  selectedConversations,
                );
              }
            } else if (val == 'pin') {
              if (allArePinned) {
                BulkActionHandler.unpinSelected(
                  context,
                  ref,
                  selectedConversations,
                );
              } else {
                BulkActionHandler.pinSelected(
                  context,
                  ref,
                  selectedConversations,
                );
              }
            }
          },
          itemBuilder: (context) => [
            if (!isDeletedView && !isArchivedView) ...[
              PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    Icon(
                      allAreRead
                          ? Icons.mark_email_unread_outlined
                          : Icons.mark_email_read_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(allAreRead ? 'Mark as unread' : 'Mark as read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'star',
                child: Row(
                  children: [
                    Icon(
                      allAreStarred ? Icons.star_border : Icons.star,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(allAreStarred ? 'Unstar' : 'Star'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(
                      allArePinned ? Icons.push_pin_outlined : Icons.push_pin,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(allArePinned ? 'Unpin' : 'Pin to top'),
                  ],
                ),
              ),
            ],
            const PopupMenuItem(
              value: 'label',
              child: Row(
                children: [
                  Icon(Icons.label_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Assign Label'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
