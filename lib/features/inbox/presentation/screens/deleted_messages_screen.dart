import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/selection/bulk_action_toolbar.dart';
import 'package:delmess/core/selection/selection_app_bar.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/core/utils/date_formatter.dart';
import 'package:delmess/core/widgets/category_badge.dart';
import 'package:delmess/core/widgets/empty_state_view.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen listing recently deleted messages with restore and permanent delete options.
class DeletedMessagesScreen extends ConsumerWidget {
  const DeletedMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.watch(driftMessageRepositoryProvider);
    final selectionState = ref.watch(selectionControllerProvider);

    return StreamBuilder<List<SmsConversation>>(
      stream: repo.watchDeletedConversations(),
      builder: (context, snapshot) {
        final deletedList = snapshot.data ?? [];

        return PopScope(
          canPop: !selectionState.isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && selectionState.isSelectionMode) {
              ref.read(selectionControllerProvider.notifier).exitSelection();
            }
          },
          child: Scaffold(
            appBar: selectionState.isSelectionMode
                ? SelectionAppBar(
                    allConversations: deletedList,
                    isDeletedView: true,
                  )
                : AppBar(
                    title: const Text('Recently Deleted'),
                    actions: [
                      if (deletedList.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          tooltip: 'Empty Trash',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Empty Trash?'),
                                content: const Text(
                                  'This will permanently delete all messages in trash. This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                    child: const Text('Delete Permanently'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final allIds = deletedList
                                  .map((c) => c.id)
                                  .toList();
                              await repo.permanentDeleteMany(allIds);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Trash emptied'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
            body: deletedList.isEmpty
                ? const EmptyStateView(
                    icon: Icons.delete_outline,
                    title: 'Trash is Empty',
                    message:
                        'Messages you delete will stay here for 30 days before permanent deletion.',
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space16,
                          vertical: AppDimensions.space12,
                        ),
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Expanded(
                              child: Text(
                                'Deleted SMS are kept here in DelMess trash. Due to Android platform security, altering the system SMS provider requires DelMess to be your default SMS app.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: deletedList.length,
                          itemBuilder: (context, index) {
                      final conversation = deletedList[index];
                      final isSelected = selectionState.isSelected(
                        conversation.id,
                      );

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.35),
                        leading: selectionState.isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  ref
                                      .read(
                                        selectionControllerProvider.notifier,
                                      )
                                      .toggleSelection(conversation.id);
                                },
                              )
                            : null,
                        title: Text(
                          conversation.senderDisplayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conversation.latestMessage.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppDimensions.space4),
                            CategoryBadge(
                              category: conversation.category,
                              compact: true,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppDateFormatter.formatConversationDate(
                                conversation.latestTimestamp,
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                            if (!selectionState.isSelectionMode)
                              IconButton(
                                icon: const Icon(Icons.restore),
                                tooltip: 'Restore conversation',
                                onPressed: () async {
                                  await repo.restore(conversation.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Restored ${conversation.senderDisplayName}',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                        onLongPress: () {
                          if (selectionState.isSelectionMode) {
                            ref
                                .read(selectionControllerProvider.notifier)
                                .toggleSelection(conversation.id);
                          } else {
                            ref
                                .read(selectionControllerProvider.notifier)
                                .enterSelection(conversation.id);
                          }
                        },
                        onTap: () {
                          if (selectionState.isSelectionMode) {
                            ref
                                .read(selectionControllerProvider.notifier)
                                .toggleSelection(conversation.id);
                          } else {
                            context.push('/messages/${conversation.id}');
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: selectionState.isSelectionMode
                ? BulkActionToolbar(
                    allConversations: deletedList,
                    isDeletedView: true,
                  )
                : null,
          ),
        );
      },
    );
  }
}
