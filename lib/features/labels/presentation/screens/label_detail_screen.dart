import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/selection/bulk_action_toolbar.dart';
import 'package:delmess/core/selection/selection_app_bar.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/core/widgets/empty_state_view.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/inbox/presentation/widgets/conversation_tile.dart';
import 'package:delmess/features/labels/presentation/controllers/labels_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen listing messages associated with a specific custom label.
class LabelDetailScreen extends ConsumerWidget {
  final String labelId;

  const LabelDetailScreen({super.key, required this.labelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsState = ref.watch(labelsControllerProvider);
    final repo = ref.watch(driftMessageRepositoryProvider);
    final selectionState = ref.watch(selectionControllerProvider);

    final label = labelsState.labels.isNotEmpty
        ? labelsState.labels.firstWhere(
            (l) => l.id == labelId,
            orElse: () => labelsState.labels.first,
          )
        : null;

    return StreamBuilder<List<SmsConversation>>(
      stream: repo.watchLabelConversations(labelId),
      builder: (context, snapshot) {
        final matchingConversations = snapshot.data ?? [];

        return PopScope(
          canPop: !selectionState.isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && selectionState.isSelectionMode) {
              ref.read(selectionControllerProvider.notifier).exitSelection();
            }
          },
          child: Scaffold(
            appBar: selectionState.isSelectionMode
                ? SelectionAppBar(allConversations: matchingConversations)
                : AppBar(
                    title: label != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(label.icon, color: label.color),
                              const SizedBox(width: 8),
                              Text(label.name),
                            ],
                          )
                        : const Text('Label Messages'),
                  ),
            body: matchingConversations.isEmpty
                ? EmptyStateView(
                    icon: label?.icon ?? Icons.label_outline,
                    title: label != null
                        ? 'No Messages with Label "${label.name}"'
                        : 'No Messages for this Label',
                    message:
                        'Tag conversations with this label to view them here.',
                  )
                : ListView.builder(
                    itemCount: matchingConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = matchingConversations[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () {
                          context.push('/messages/${conversation.id}');
                        },
                      );
                    },
                  ),
            bottomNavigationBar: selectionState.isSelectionMode
                ? BulkActionToolbar(allConversations: matchingConversations)
                : null,
          ),
        );
      },
    );
  }
}
