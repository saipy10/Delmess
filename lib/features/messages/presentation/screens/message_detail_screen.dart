import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/selection/label_assignment_dialog.dart';
import 'package:delmess/core/utils/date_formatter.dart';
import 'package:delmess/core/utils/string_utils.dart';
import 'package:delmess/core/widgets/app_cards.dart';
import 'package:delmess/core/widgets/category_badge.dart';
import 'package:delmess/core/widgets/loading_state_view.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:delmess/features/messages/presentation/controllers/message_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Message Detail Screen showing threaded view of messages from a sender.
class MessageDetailScreen extends ConsumerWidget {
  final String conversationId;

  const MessageDetailScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final conversationAsync = ref.watch(
      conversationDetailProvider(conversationId),
    );

    return conversationAsync.when(
      loading: () => const Scaffold(
        body: LoadingStateView(message: 'Loading conversation...'),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Failed to load message: $err')),
      ),
      data: (conversation) {
        if (conversation == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Message Detail')),
            body: const Center(child: Text('Conversation not found.')),
          );
        }

        final categoryColor = conversation.category.getColor(context);
        final categoryBgColor = conversation.category.getBackgroundColor(
          context,
        );
        final repo = ref.read(driftMessageRepositoryProvider);

        // Automatically mark conversation as read upon viewing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          repo.markRead(conversation.id);
        });

        // Sort messages chronologically (oldest first, newest last)
        final messages = List<SmsMessage>.from(conversation.messages)
          ..sort((a, b) => a.receivedAt.compareTo(b.receivedAt));

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.senderDisplayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  conversation.sender,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  conversation.isStarred ? Icons.star : Icons.star_border,
                  color: conversation.isStarred ? Colors.amber : null,
                ),
                tooltip: conversation.isStarred ? 'Unstar Conversation' : 'Star Conversation',
                onPressed: () async {
                  if (conversation.isStarred) {
                    await repo.unstar(conversation.id);
                  } else {
                    await repo.star(conversation.id);
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  conversation.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  color: conversation.isPinned
                      ? theme.colorScheme.primary
                      : null,
                ),
                tooltip: conversation.isPinned ? 'Unpin' : 'Pin',
                onPressed: () async {
                  if (conversation.isPinned) {
                    await repo.unpin(conversation.id);
                  } else {
                    await repo.pin(conversation.id);
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'label_conv') {
                    final allMsgIds = conversation.messages.map((m) => m.id).toList();
                    final commonLabelIds = <String>{};
                    for (final m in conversation.messages) {
                      for (final l in m.labels) {
                        commonLabelIds.add(l.id);
                      }
                    }
                    await showDialog(
                      context: context,
                      builder: (context) => LabelAssignmentDialog(
                        messageIds: allMsgIds,
                        initialSelectedLabelIds: commonLabelIds,
                      ),
                    );
                  } else if (value == 'mark_unread') {
                    await repo.markUnread(conversation.id);
                    if (context.mounted) context.pop();
                  } else if (value == 'archive') {
                    if (conversation.isArchived) {
                      await repo.unarchive(conversation.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conversation restored to Inbox'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } else {
                      await repo.archive(conversation.id);
                      if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Conversation archived'),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () => repo.unarchive(conversation.id),
                            ),
                          ),
                        );
                      }
                    }
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Conversation?'),
                        content: const Text(
                          'This will move all messages in this conversation to Recently Deleted.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await repo.softDelete(conversation.id);
                      if (context.mounted) {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Conversation moved to Trash'),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () => repo.restore(conversation.id),
                            ),
                          ),
                        );
                      }
                    }
                  } else if (value == 'classification_info') {
                    _showClassificationDetails(
                      context,
                      conversation.latestMessage,
                      conversation.senderDisplayName,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'classification_info',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Sender & Classification Info'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'label_conv',
                    child: Row(
                      children: [
                        Icon(Icons.label_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Add Label'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_unread',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_unread_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Mark as unread'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          conversation.isArchived
                              ? Icons.unarchive_outlined
                              : Icons.archive_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          conversation.isArchived
                              ? 'Unarchive conversation'
                              : 'Archive conversation',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Delete conversation',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Category Banner Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space8,
                ),
                color: categoryBgColor.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    CategoryBadge(category: conversation.category),
                    const SizedBox(width: AppDimensions.space8),
                    Expanded(
                      child: Text(
                        conversation.category.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Chronological message stream with date separators
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final extractedOtp =
                        message.otp ?? StringUtils.extractOtp(message.body);

                    // Check if date divider is needed
                    bool showDateDivider = false;
                    if (index == 0) {
                      showDateDivider = true;
                    } else {
                      final prevDate = messages[index - 1].receivedAt;
                      final currDate = message.receivedAt;
                      if (prevDate.year != currDate.year ||
                          prevDate.month != currDate.month ||
                          prevDate.day != currDate.day) {
                        showDateDivider = true;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateDivider) ...[
                          _buildDateDivider(context, message.receivedAt),
                          const SizedBox(height: AppDimensions.space12),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.space16,
                          ),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppDimensions.space16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Message Header: Sender variation/suffix + exact time + Star
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (message.messageTypeSuffix != null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '-${message.messageTypeSuffix}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          AppDateFormatter.formatTime(
                                            message.receivedAt,
                                          ),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        message.isStarred
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: AppDimensions.iconSm,
                                        color: message.isStarred
                                            ? Colors.amber.shade700
                                            : theme.colorScheme.outlineVariant,
                                      ),
                                      tooltip: message.isStarred
                                          ? 'Unstar message'
                                          : 'Star message',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        if (message.isStarred) {
                                          await repo.unstarMessage(message.id);
                                        } else {
                                          await repo.starMessage(message.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.space8),

                                // Message Body Text
                                SelectableText(
                                  message.body,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                  ),
                                ),

                                // Prominent High-Contrast OTP Card if detected
                                if (extractedOtp != null) ...[
                                  const SizedBox(height: AppDimensions.space16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.space16,
                                      vertical: AppDimensions.space12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer
                                          .withValues(alpha: 0.5),
                                      borderRadius:
                                          AppDimensions.borderRadiusMd,
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.35),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isCompact =
                                            constraints.maxWidth < 280;

                                        final copyOtpButton = FilledButton.icon(
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(text: extractedOtp),
                                            );
                                            HapticFeedback.mediumImpact();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'OTP $extractedOtp copied to clipboard',
                                                ),
                                                duration:
                                                    const Duration(seconds: 2),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Copy OTP',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            foregroundColor:
                                                theme.colorScheme.onPrimary,
                                            visualDensity:
                                                VisualDensity.compact,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );

                                        if (isCompact) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                              alpha: 0.15),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.security,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      size: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: AppDimensions.space8,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      'VERIFICATION CODE / OTP',
                                                      style: theme
                                                          .textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                            color: theme
                                                                .colorScheme
                                                                .primary,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 0.8,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: AppDimensions.space8,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: SelectableText(
                                                      extractedOtp,
                                                      style: theme
                                                          .textTheme
                                                          .headlineSmall
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            letterSpacing: 2.0,
                                                            color: theme
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: AppDimensions.space8,
                                                  ),
                                                  copyOtpButton,
                                                ],
                                              ),
                                            ],
                                          );
                                        }

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                              alpha: 0.15),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.security,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      size: AppDimensions
                                                          .iconSm,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: AppDimensions
                                                        .space12,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'VERIFICATION CODE / OTP',
                                                          style: theme
                                                              .textTheme
                                                              .labelSmall
                                                              ?.copyWith(
                                                                color: theme
                                                                    .colorScheme
                                                                    .primary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                letterSpacing:
                                                                    0.8,
                                                              ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        SelectableText(
                                                          extractedOtp,
                                                          style: theme
                                                              .textTheme
                                                              .headlineSmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                letterSpacing:
                                                                    2.5,
                                                                color: theme
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppDimensions.space8,
                                            ),
                                            copyOtpButton,
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],

                                // User Labels on Message if present
                                if (message.labels.isNotEmpty) ...[
                                  const SizedBox(height: AppDimensions.space12),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: message.labels.map((lbl) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: lbl.color.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: lbl.color.withValues(
                                              alpha: 0.4,
                                            ),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          lbl.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: lbl.color,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                const SizedBox(height: AppDimensions.space12),
                                const Divider(height: 1),
                                const SizedBox(height: AppDimensions.space8),

                                // Granular Message Action Bar
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.label_outline,
                                        size: AppDimensions.iconSm,
                                      ),
                                      tooltip: 'Labels',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              LabelAssignmentDialog(
                                            messageIds: [message.id],
                                            initialSelectedLabelIds: message
                                                .labels
                                                .map((l) => l.id)
                                                .toSet(),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy_outlined,
                                        size: AppDimensions.iconSm,
                                      ),
                                      tooltip: 'Copy message text',
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: message.body),
                                        );
                                        HapticFeedback.lightImpact();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Message text copied to clipboard',
                                            ),
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.info_outline,
                                        size: AppDimensions.iconSm,
                                      ),
                                      tooltip: 'Classification details',
                                      onPressed: () {
                                        _showClassificationDetails(
                                          context,
                                          message,
                                          conversation.senderDisplayName,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        size: AppDimensions.iconSm,
                                        color: theme.colorScheme.error,
                                      ),
                                      tooltip: 'Delete message',
                                      onPressed: () async {
                                        await repo.deleteMessage(message.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Message moved to Trash',
                                              ),
                                              duration: Duration(seconds: 2),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateDivider(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppDateFormatter.formatChatDivider(date),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _showClassificationDetails(
    BuildContext context,
    SmsMessage message,
    String senderDisplayName,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Message Classification & Sender Info',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: AppDimensions.space12),
                _buildDetailRow(
                  theme,
                  'Brand',
                  message.brandName.isNotEmpty
                      ? message.brandName
                      : senderDisplayName,
                ),
                _buildDetailRow(
                  theme,
                  'Clean Header',
                  message.parsedHeader ?? message.header,
                ),
                _buildDetailRow(
                  theme,
                  'Raw Sender',
                  message.effectiveRawSender,
                ),
                _buildDetailRow(
                  theme,
                  'Operator Prefix',
                  message.operatorPrefix ?? 'None',
                ),
                _buildDetailRow(
                  theme,
                  'Suffix',
                  message.messageTypeSuffix != null
                      ? '-${message.messageTypeSuffix}'
                      : 'None',
                ),
                _buildDetailRow(
                  theme,
                  'Category',
                  message.category.displayName,
                ),
                _buildDetailRow(
                  theme,
                  'Confidence',
                  '${(message.classificationConfidence * 100).toInt()}%',
                ),
                _buildDetailRow(
                  theme,
                  'Reason',
                  message.effectiveReasonDescription,
                ),
                _buildDetailRow(
                  theme,
                  'Classifier Version',
                  'v${message.classificationVersion}',
                ),
                const SizedBox(height: AppDimensions.space16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
