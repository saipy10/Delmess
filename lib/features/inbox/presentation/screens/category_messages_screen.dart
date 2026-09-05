import 'package:delmess/core/constants/category_constants.dart';
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

/// Screen displaying messages for a specific category.
class CategoryMessagesScreen extends ConsumerWidget {
  final CategoryType category;

  const CategoryMessagesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(driftMessageRepositoryProvider);
    final selectionState = ref.watch(selectionControllerProvider);

    return StreamBuilder<List<SmsConversation>>(
      stream: repo.watchCategoryConversations(category),
      builder: (context, snapshot) {
        final categoryList = snapshot.data ?? [];

        return PopScope(
          canPop: !selectionState.isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && selectionState.isSelectionMode) {
              ref.read(selectionControllerProvider.notifier).exitSelection();
            }
          },
          child: Scaffold(
            appBar: selectionState.isSelectionMode
                ? SelectionAppBar(allConversations: categoryList)
                : AppBar(
                    title: Row(
                      children: [
                        Icon(category.icon, color: category.getColor(context)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            category.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
            body: categoryList.isEmpty
                ? EmptyStateView(
                    icon: category.icon,
                    title: 'No ${category.displayName} Messages',
                    message:
                        'Messages categorized under ${category.displayName} will appear here.',
                  )
                : ListView.builder(
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      final conversation = categoryList[index];
                      return ConversationTile(
                        conversation: conversation,
                        onTap: () {
                          context.push('/messages/${conversation.id}');
                        },
                      );
                    },
                  ),
            bottomNavigationBar: selectionState.isSelectionMode
                ? BulkActionToolbar(allConversations: categoryList)
                : null,
          ),
        );
      },
    );
  }
}
