import 'package:delmess/core/constants/app_dimensions.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/core/utils/date_formatter.dart';
import 'package:delmess/core/utils/string_utils.dart';
import 'package:delmess/core/widgets/category_badge.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rich conversation tile for inbox and list views with multi-selection support.
class ConversationTile extends ConsumerWidget {
  final SmsConversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectionState = ref.watch(selectionControllerProvider);
    final isSelected = selectionState.isSelected(conversation.id);
    final isSelectionMode = selectionState.isSelectionMode;

    final latestMessage = conversation.latestMessage;
    final hasUnread = conversation.hasUnread;
    final categoryColor = conversation.category.getColor(context);
    final categoryBgColor = conversation.category.getBackgroundColor(context);

    // Compute background color based on selection and unread state
    Color tileColor = Colors.transparent;
    if (isSelected) {
      tileColor = theme.colorScheme.primaryContainer.withValues(
        alpha: isDark ? 0.35 : 0.45,
      );
    } else if (hasUnread) {
      tileColor = isDark
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.25);
    }

    final tileWidget = Semantics(
      selected: isSelected,
      label:
          '${conversation.senderDisplayName}, ${conversation.category.displayName}, ${hasUnread ? "Unread" : "Read"}, ${conversation.isStarred ? "Starred" : ""}, ${conversation.isPinned ? "Pinned" : ""}, ${conversation.messages.length} messages',
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            ref
                .read(selectionControllerProvider.notifier)
                .toggleSelection(conversation.id);
          } else {
            // Mark as read in repository
            ref.read(driftMessageRepositoryProvider).markRead(conversation.id);
            onTap();
          }
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          if (isSelectionMode) {
            ref
                .read(selectionControllerProvider.notifier)
                .toggleSelection(conversation.id);
          } else {
            ref
                .read(selectionControllerProvider.notifier)
                .enterSelection(conversation.id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
          decoration: BoxDecoration(
            color: tileColor,
            border: Border(
              left: isSelected
                  ? BorderSide(color: theme.colorScheme.primary, width: 4.0)
                  : BorderSide.none,
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar or Selection Checkbox
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: isSelected
                    ? Container(
                        key: const ValueKey('selected_check'),
                        width: AppDimensions.avatarSm + 8,
                        height: AppDimensions.avatarSm + 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                      )
                    : CircleAvatar(
                        key: const ValueKey('avatar_circle'),
                        radius: AppDimensions.avatarSm / 2 + 4,
                        backgroundColor: categoryBgColor,
                        child: Text(
                          StringUtils.getInitials(
                            conversation.senderDisplayName,
                          ),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // Main Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Sender name, Message count, Pinned icon, Date, Unread Dot
                    Row(
                      children: [
                        if (conversation.isPinned) ...[
                          Icon(
                            Icons.push_pin,
                            size: AppDimensions.iconXs + 2,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppDimensions.space4),
                        ],
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  conversation.senderDisplayName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: hasUnread
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (conversation.messages.length > 1) ...[
                                const SizedBox(width: AppDimensions.space6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${conversation.messages.length}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppDateFormatter.formatConversationDate(
                                conversation.latestTimestamp,
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: hasUnread
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (hasUnread) ...[
                              const SizedBox(width: AppDimensions.space6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space4),

                    // Message snippet
                    Text(
                      latestMessage.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasUnread
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.space8),

                    // Footer badges: Category + OTP chip + Labels + Star button
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CategoryBadge(
                                  category: conversation.category,
                                  compact: true,
                                ),
                                if (latestMessage.otp != null ||
                                    StringUtils.extractOtp(latestMessage.body) != null) ...[
                                  () {
                                    final otpCode = latestMessage.otp ??
                                        StringUtils.extractOtp(latestMessage.body)!;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: AppDimensions.space8,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Clipboard.setData(
                                            ClipboardData(text: otpCode),
                                          );
                                          HapticFeedback.lightImpact();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'OTP $otpCode copied to clipboard',
                                              ),
                                              duration: const Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        borderRadius: AppDimensions.borderRadiusSm,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppDimensions.space8,
                                            vertical: AppDimensions.space2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                theme.colorScheme.primaryContainer,
                                            borderRadius:
                                                AppDimensions.borderRadiusSm,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.copy,
                                                size: AppDimensions.iconXs,
                                                color: theme
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                              const SizedBox(
                                                width: AppDimensions.space4,
                                              ),
                                              Text(
                                                'OTP: $otpCode',
                                                style: theme.textTheme.labelSmall
                                                    ?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: theme
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }(),
                                ],
                                if (conversation.labels.isNotEmpty) ...[
                                  const SizedBox(width: AppDimensions.space8),
                                  ...conversation.labels
                                      .take(2)
                                      .map(
                                        (lbl) => Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: lbl.color.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: lbl.color,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (!isSelectionMode) ...[
                          const SizedBox(width: AppDimensions.space4),
                          IconButton(
                            icon: Icon(
                              conversation.isStarred
                                  ? Icons.star
                                  : Icons.star_border,
                              size: AppDimensions.iconSm,
                              color: conversation.isStarred
                                  ? Colors.amber.shade700
                                  : theme.colorScheme.outlineVariant,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final repo = ref.read(
                                driftMessageRepositoryProvider,
                              );
                              if (conversation.isStarred) {
                                repo.unstar(conversation.id);
                              } else {
                                repo.star(conversation.id);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // If multi-select is active, do not intercept swipes
    if (isSelectionMode) {
      return tileWidget;
    }

    // Dismissible swipe actions: Right = Read/Unread, Left = Archive
    return Dismissible(
      key: ValueKey('dismiss_${conversation.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: hasUnread ? theme.colorScheme.primary : theme.colorScheme.secondary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
        child: Row(
          children: [
            Icon(
              hasUnread
                  ? Icons.mark_email_read_outlined
                  : Icons.mark_email_unread_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: AppDimensions.space8),
            Text(
              hasUnread ? 'Mark Read' : 'Mark Unread',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: conversation.isArchived
            ? theme.colorScheme.primary
            : Colors.amber.shade800,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              conversation.isArchived ? 'Unarchive' : 'Archive',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Icon(
              conversation.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
              color: Colors.white,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final repo = ref.read(driftMessageRepositoryProvider);
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right: Toggle Read / Unread (bounce back with false)
          if (hasUnread) {
            await repo.markRead(conversation.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Marked as read'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () => repo.markUnread(conversation.id),
                  ),
                ),
              );
            }
          } else {
            await repo.markUnread(conversation.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Marked as unread'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () => repo.markRead(conversation.id),
                  ),
                ),
              );
            }
          }
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // Swipe Left: Archive / Unarchive
          if (conversation.isArchived) {
            await repo.unarchive(conversation.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Conversation unarchived'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () => repo.archive(conversation.id),
                  ),
                ),
              );
            }
          } else {
            await repo.archive(conversation.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
          return true;
        }
        return false;
      },
      child: tileWidget,
    );
  }
}
