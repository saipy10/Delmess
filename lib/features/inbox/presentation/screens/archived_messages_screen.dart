import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/selection/bulk_action_toolbar.dart';
import 'package:delmess/core/selection/selection_app_bar.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/core/widgets/empty_state_view.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/inbox/presentation/widgets/conversation_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen listing archived SMS conversations.
class ArchivedMessagesScreen extends ConsumerWidget {
  const ArchivedMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(driftMessageRepositoryProvider);
    final selectionState = ref.watch(selectionControllerProvider);

    return StreamBuilder<List<SmsConversation>>(
      stream: repo.watchArchivedConversations(),
      builder: (context, snapshot) {
        final archivedList = snapshot.data ?? [];

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
                    allConversations: archivedList,
                    isArchivedView: true,
                  )
                : AppBar(title: const Text('Archived Messages')),
            body: archivedList.isEmpty
                ? const EmptyStateView(
                    icon: Icons.archive_outlined,
                    title: 'No Archived Messages',
                    message:
                        'Archived conversations will be stored here away from your primary inbox.',
                  )
                : ListView.builder(
                    itemCount: archivedList.length,
                    itemBuilder: (context, index) {
                      final conversation = archivedList[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () {
                          context.push('/messages/${conversation.id}');
                        },
                      );
                    },
                  ),
            bottomNavigationBar: selectionState.isSelectionMode
                ? BulkActionToolbar(
                    allConversations: archivedList,
                    isArchivedView: true,
                  )
                : null,
          ),
        );
      },
    );
  }
}
