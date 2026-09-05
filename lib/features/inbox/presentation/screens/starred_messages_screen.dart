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

/// Screen listing starred SMS conversations.
class StarredMessagesScreen extends ConsumerWidget {
  const StarredMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(driftMessageRepositoryProvider);
    final selectionState = ref.watch(selectionControllerProvider);

    return StreamBuilder<List<SmsConversation>>(
      stream: repo.watchStarredConversations(),
      builder: (context, snapshot) {
        final starredList = snapshot.data ?? [];

        return PopScope(
          canPop: !selectionState.isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && selectionState.isSelectionMode) {
              ref.read(selectionControllerProvider.notifier).exitSelection();
            }
          },
          child: Scaffold(
            appBar: selectionState.isSelectionMode
                ? SelectionAppBar(allConversations: starredList)
                : AppBar(title: const Text('Starred Messages')),
            body: starredList.isEmpty
                ? const EmptyStateView(
                    icon: Icons.star_border,
                    title: 'No Starred Messages',
                    message:
                        'Star important messages to quickly access them here anytime.',
                  )
                : ListView.builder(
                    itemCount: starredList.length,
                    itemBuilder: (context, index) {
                      final conversation = starredList[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () {
                          context.push('/messages/${conversation.id}');
                        },
                      );
                    },
                  ),
            bottomNavigationBar: selectionState.isSelectionMode
                ? BulkActionToolbar(allConversations: starredList)
                : null,
          ),
        );
      },
    );
  }
}
