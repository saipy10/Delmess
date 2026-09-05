import 'package:delmess/core/constants/app_strings.dart';
import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/database/database_seed_service.dart';
import 'package:delmess/core/routing/route_paths.dart';
import 'package:delmess/core/selection/bulk_action_toolbar.dart';
import 'package:delmess/core/selection/selection_app_bar.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/core/widgets/empty_state_view.dart';
import 'package:delmess/core/widgets/loading_state_view.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/inbox/presentation/controllers/inbox_controller.dart';
import 'package:delmess/features/inbox/presentation/controllers/sms_permission_controller.dart';
import 'package:delmess/features/inbox/presentation/widgets/conversation_tile.dart';
import 'package:delmess/features/inbox/presentation/widgets/inbox_category_bar.dart';
import 'package:delmess/features/inbox/presentation/widgets/inbox_drawer.dart';
import 'package:delmess/features/classification/domain/message_classification_service.dart';
import 'package:delmess/features/messages/data/sms_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main Inbox screen for DelMess SMS Organizer with real SMS database backing and multi-select.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final inboxState = ref.watch(inboxControllerProvider);
    final selectionState = ref.watch(selectionControllerProvider);
    final permState = ref.watch(smsPermissionControllerProvider);
    final conversations = inboxState.filteredConversations;

    return PopScope(
      canPop: !selectionState.isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectionState.isSelectionMode) {
          ref.read(selectionControllerProvider.notifier).exitSelection();
        }
      },
      child: Scaffold(
        drawer: selectionState.isSelectionMode ? null : const InboxDrawer(),
        appBar: selectionState.isSelectionMode
            ? SelectionAppBar(allConversations: conversations)
            : AppBar(
                title: Text(
                  inboxState.selectedCategory != null
                      ? inboxState.selectedCategory!.displayName
                      : AppStrings.appName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search SMS',
                    onPressed: () => context.push(RoutePaths.search),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'clear_filter') {
                        ref
                            .read(inboxControllerProvider.notifier)
                            .selectCategory(null);
                      } else if (value == 'sync') {
                        context.push(RoutePaths.import);
                      } else if (value == 'starred') {
                        context.push(RoutePaths.starred);
                      } else if (value == 'pinned') {
                        context.push(RoutePaths.pinned);
                      } else if (value == 'archived') {
                        context.push(RoutePaths.archived);
                      } else if (value == 'reclassify') {
                        final count = await ref
                            .read(messageClassificationServiceProvider)
                            .reclassifyAllMessages();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reprocessed and categorized $count messages!',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else if (value == 'reseed') {
                        final seeder = DatabaseSeedService(
                          messageRepo: ref.read(driftMessageRepositoryProvider),
                          labelRepo: ref.read(driftLabelRepositoryProvider),
                          senderRepo: ref.read(
                            driftSenderMetadataRepositoryProvider,
                          ),
                          db: ref.read(appDatabaseProvider),
                        );
                        await seeder.resetAndSeed();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sample SMS dataset re-seeded!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      if (inboxState.selectedCategory != null)
                        const PopupMenuItem(
                          value: 'clear_filter',
                          child: Row(
                            children: [
                              Icon(Icons.filter_alt_off_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Clear category filter'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'sync',
                        child: Row(
                          children: [
                            Icon(Icons.sync, size: 20),
                            SizedBox(width: 12),
                            Text('Sync Device SMS'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'reclassify',
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Reprocess Categories'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'starred',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, size: 20),
                            SizedBox(width: 12),
                            Text('Starred messages'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pinned',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Pinned messages'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'archived',
                        child: Row(
                          children: [
                            Icon(Icons.archive_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Archived messages'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'reseed',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 12),
                            Text('Reset & Seed Demo Data'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        body: Column(
          children: [
            // Category quick-filter tabs
            const InboxCategoryBar(),
            const Divider(height: 1),

            // Message list or Empty/Loading State
            Expanded(
              child: inboxState.isLoading
                  ? const LoadingStateView(message: 'Loading SMS database...')
                  : conversations.isEmpty
                  ? EmptyStateView(
                      icon:
                          inboxState.selectedCategory?.icon ??
                          Icons.inbox_outlined,
                      title: _getEmptyTitle(inboxState.selectedCategory),
                      message: _getEmptyMessage(inboxState.selectedCategory),
                      actionLabel: inboxState.selectedCategory != null
                          ? 'View All Messages'
                          : (permState != SmsPermissionState.granted
                                ? 'Grant SMS Access'
                                : 'Sync Messages'),
                      onAction: () async {
                        if (inboxState.selectedCategory != null) {
                          ref
                              .read(inboxControllerProvider.notifier)
                              .selectCategory(null);
                        } else if (permState != SmsPermissionState.granted) {
                          context.push(RoutePaths.permissions);
                        } else {
                          context.push(RoutePaths.import);
                        }
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(smsSyncServiceProvider)
                            .syncIncrementalMessages();
                      },
                      child: _buildConversationList(context, conversations),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: selectionState.isSelectionMode
            ? BulkActionToolbar(allConversations: conversations)
            : null,
      ),
    );
  }

  Widget _buildConversationList(
    BuildContext context,
    List<SmsConversation> conversations,
  ) {
    final pinned = conversations.where((c) => c.isPinned).toList();
    final recent = conversations.where((c) => !c.isPinned).toList();

    // If there are pinned conversations, partition into PINNED and RECENT sections
    if (pinned.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildSectionHeader(context, 'PINNED', Icons.push_pin_outlined),
          ...pinned.map(
            (c) => ConversationTile(
              conversation: c,
              onTap: () => context.push('/messages/${c.id}'),
            ),
          ),
          _buildSectionHeader(context, 'RECENT', Icons.access_time_outlined),
          ...recent.map(
            (c) => ConversationTile(
              conversation: c,
              onTap: () => context.push('/messages/${c.id}'),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationTile(
          conversation: conversation,
          onTap: () {
            context.push('/messages/${conversation.id}');
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyTitle(CategoryType? category) {
    if (category == null) return 'No messages yet';
    switch (category) {
      case CategoryType.promotional:
        return 'No promotional messages';
      case CategoryType.transactional:
        return 'No transactional messages';
      case CategoryType.service:
        return 'No service messages';
      case CategoryType.government:
        return 'No government messages';
      case CategoryType.other:
        return 'No personal or other messages';
    }
    return 'No messages';
  }

  String _getEmptyMessage(CategoryType? category) {
    if (category == null) {
      return 'When you receive SMS messages, they\'ll appear here automatically.';
    }
    switch (category) {
      case CategoryType.promotional:
        return 'New promotional SMS, deals, and discounts will automatically appear here.';
      case CategoryType.transactional:
        return 'Bank alerts, account debits, and credit SMS will automatically appear here.';
      case CategoryType.service:
        return 'One-time passwords (OTPs), order updates, and service notifications will appear here.';
      case CategoryType.government:
        return 'Official communications from UIDAI, Income Tax, and govt services will appear here.';
      case CategoryType.other:
        return 'Direct messages and unclassified personal SMS will appear here.';
    }
    return 'SMS will appear here automatically.';
  }
}
