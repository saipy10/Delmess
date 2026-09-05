import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/selection/label_assignment_dialog.dart';
import 'package:delmess/core/selection/selection_controller.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkActionHandler {
  static Future<void> archiveSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.archiveMany(ids);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ids.length} message(s) archived'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await repo.unarchiveMany(ids);
            },
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> unarchiveSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.unarchiveMany(ids);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ids.length} message(s) restored to Inbox'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await repo.archiveMany(ids);
            },
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> deleteSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.softDeleteMany(ids);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ids.length} message(s) moved to Trash'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await repo.restoreMany(ids);
            },
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> restoreSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.restoreMany(ids);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ids.length} message(s) restored'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await repo.softDeleteMany(ids);
            },
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> markReadSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.markReadMany(ids);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ids.length} message(s) marked as read'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> markUnreadSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.markUnreadMany(ids);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ids.length} message(s) marked as unread'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> starSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.starMany(ids);
  }

  static Future<void> unstarSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.unstarMany(ids);
  }

  static Future<void> pinSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.pinMany(ids);
  }

  static Future<void> unpinSelected(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final repo = ref.read(driftMessageRepositoryProvider);
    final ids = selectedItems.map((c) => c.id).toList();
    if (ids.isEmpty) return;

    ref.read(selectionControllerProvider.notifier).exitSelection();
    await repo.unpinMany(ids);
  }

  static Future<void> showLabelDialog(
    BuildContext context,
    WidgetRef ref,
    List<SmsConversation> selectedItems,
  ) async {
    final msgIds = <String>[];
    final commonLabelIds = <String>{};

    for (final conv in selectedItems) {
      for (final msg in conv.messages) {
        msgIds.add(msg.id);
        for (final l in msg.labels) {
          commonLabelIds.add(l.id);
        }
      }
    }

    if (msgIds.isEmpty) return;

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => LabelAssignmentDialog(
        messageIds: msgIds,
        initialSelectedLabelIds: commonLabelIds,
      ),
    );

    if (updated == true) {
      ref.read(selectionControllerProvider.notifier).exitSelection();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Labels updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
