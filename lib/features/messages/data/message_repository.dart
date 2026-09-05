import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/classification/domain/message_category.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FolderCounts {
  final int totalInbox;
  final int unreadInbox;
  final int starred;
  final int pinned;
  final int archived;
  final int deleted;

  const FolderCounts({
    this.totalInbox = 0,
    this.unreadInbox = 0,
    this.starred = 0,
    this.pinned = 0,
    this.archived = 0,
    this.deleted = 0,
  });
}

abstract class MessageRepository {
  Stream<List<SmsConversation>> watchInboxConversations({
    CategoryType? category,
  });
  Stream<List<SmsConversation>> watchStarredConversations();
  Stream<List<SmsConversation>> watchPinnedConversations();
  Stream<List<SmsConversation>> watchArchivedConversations();
  Stream<List<SmsConversation>> watchDeletedConversations();
  Stream<List<SmsConversation>> watchCategoryConversations(
    CategoryType category,
  );
  Stream<List<SmsConversation>> watchLabelConversations(String labelId);

  Stream<FolderCounts> watchFolderCounts();
  Stream<Map<CategoryType, int>> watchCategoryCounts();
  Stream<Map<CategoryType, int>> watchCategoryUnreadCounts();

  Future<SmsMessage?> getMessageById(String id);
  Future<SmsConversation?> getConversationById(String conversationId);
  Future<List<SmsMessage>> getMessagesByThread(String threadId);
  Future<List<SmsMessage>> getAllMessages();
  Future<int> getMessageCount();
  Future<List<SmsMessage>> getMessagesPaged({
    required int limit,
    required int offset,
  });

  Future<void> insertMessage(SmsMessage message);
  Future<void> insertMessages(List<SmsMessage> messages);

  // Single updates
  Future<void> markRead(String id);
  Future<void> markUnread(String id);
  Future<void> star(String id);
  Future<void> unstar(String id);
  Future<void> pin(String id);
  Future<void> unpin(String id);
  Future<void> archive(String id);
  Future<void> unarchive(String id);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> permanentDelete(String id);

  // Bulk updates with database transactions
  Future<void> markReadMany(List<String> ids);
  Future<void> markUnreadMany(List<String> ids);
  Future<void> starMany(List<String> ids);
  Future<void> unstarMany(List<String> ids);
  Future<void> pinMany(List<String> ids);
  Future<void> unpinMany(List<String> ids);
  Future<void> archiveMany(List<String> ids);
  Future<void> unarchiveMany(List<String> ids);
  Future<void> softDeleteMany(List<String> ids);
  Future<void> restoreMany(List<String> ids);
  Future<void> permanentDeleteMany(List<String> ids);

  // Granular conversation watching and single-message controls
  Stream<SmsConversation?> watchConversation(String conversationId);
  Future<void> starMessage(String messageId);
  Future<void> unstarMessage(String messageId);
  Future<void> deleteMessage(String messageId);
  Future<void> markMessageRead(String messageId);
}

class DriftMessageRepository implements MessageRepository {
  final AppDatabase _db;

  DriftMessageRepository(this._db);

  @override
  Stream<List<SmsConversation>> watchInboxConversations({
    CategoryType? category,
  }) {
    var query = _db.select(_db.messages)
      ..where(
        (tbl) => tbl.isDeleted.equals(false) & tbl.isArchived.equals(false),
      );

    if (category != null) {
      query = query..where((tbl) => tbl.category.equals(category.name));
    }

    query = query
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ]);

    return _buildConversationStream(query);
  }

  @override
  Stream<List<SmsConversation>> watchStarredConversations() {
    final query = _db.select(_db.messages)
      ..where((tbl) => tbl.isDeleted.equals(false) & tbl.isStarred.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ]);
    return _buildConversationStream(query);
  }

  @override
  Stream<List<SmsConversation>> watchPinnedConversations() {
    final query = _db.select(_db.messages)
      ..where((tbl) => tbl.isDeleted.equals(false) & tbl.isPinned.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ]);
    return _buildConversationStream(query);
  }

  @override
  Stream<List<SmsConversation>> watchArchivedConversations() {
    final query = _db.select(_db.messages)
      ..where(
        (tbl) => tbl.isDeleted.equals(false) & tbl.isArchived.equals(true),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ]);
    return _buildConversationStream(query);
  }

  @override
  Stream<List<SmsConversation>> watchDeletedConversations() {
    final query = _db.select(_db.messages)
      ..where((tbl) => tbl.isDeleted.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ]);
    return _buildConversationStream(query);
  }

  @override
  Stream<List<SmsConversation>> watchCategoryConversations(
    CategoryType category,
  ) {
    final query = _db.select(_db.messages)
      ..where(
        (tbl) =>
            tbl.isDeleted.equals(false) &
            tbl.isArchived.equals(false) &
            tbl.category.equals(category.name),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ]);
    return _buildConversationStream(query);
  }

  @override
  Stream<List<SmsConversation>> watchLabelConversations(String labelId) {
    final msgIdsQuery = _db.select(_db.messageLabels)
      ..where((tbl) => tbl.labelId.equals(labelId));

    return msgIdsQuery.watch().asyncMap((rels) async {
      final msgIds = rels.map((r) => r.messageId).toList();
      if (msgIds.isEmpty) return [];

      final query = _db.select(_db.messages)
        ..where((tbl) => tbl.id.isIn(msgIds) & tbl.isDeleted.equals(false))
        ..orderBy([
          (t) =>
              OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
        ]);

      final rawMessages = await query.get();
      return _groupToConversations(rawMessages);
    });
  }

  @override
  Stream<FolderCounts> watchFolderCounts() {
    return _db.select(_db.messages).watch().map((allMsgs) {
      int totalInbox = 0;
      int unreadInbox = 0;
      int starred = 0;
      int pinned = 0;
      int archived = 0;
      int deleted = 0;

      for (final m in allMsgs) {
        if (m.isDeleted) {
          deleted++;
        } else {
          if (m.isArchived) {
            archived++;
          } else {
            totalInbox++;
            if (!m.isRead) {
              unreadInbox++;
            }
          }
          if (m.isStarred) starred++;
          if (m.isPinned) pinned++;
        }
      }

      return FolderCounts(
        totalInbox: totalInbox,
        unreadInbox: unreadInbox,
        starred: starred,
        pinned: pinned,
        archived: archived,
        deleted: deleted,
      );
    });
  }

  @override
  Stream<Map<CategoryType, int>> watchCategoryCounts() {
    return _db.select(_db.messages).watch().map((messages) {
      final counts = <CategoryType, int>{
        for (final cat in CategoryType.values) cat: 0,
      };
      for (final m in messages) {
        if (!m.isDeleted && !m.isArchived) {
          final cat = CategoryTypeExtension.fromString(m.category);
          counts[cat] = (counts[cat] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  @override
  Stream<Map<CategoryType, int>> watchCategoryUnreadCounts() {
    return _db.select(_db.messages).watch().map((messages) {
      final counts = <CategoryType, int>{
        for (final cat in CategoryType.values) cat: 0,
      };
      for (final m in messages) {
        if (!m.isDeleted && !m.isArchived && !m.isRead) {
          final cat = CategoryTypeExtension.fromString(m.category);
          counts[cat] = (counts[cat] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  @override
  Future<SmsMessage?> getMessageById(String id) async {
    final query = _db.select(_db.messages)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final labels = await _getLabelsForMessage(id);
    return _mapRowToMessage(row, labels);
  }

  @override
  Future<SmsConversation?> getConversationById(String conversationId) async {
    // A conversation is identified by threadId or id
    final query = _db.select(_db.messages)
      ..where(
        (tbl) =>
            tbl.threadId.equals(conversationId) | tbl.id.equals(conversationId),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ]);

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final conversations = await _groupToConversations(rows);
    return conversations.isNotEmpty ? conversations.first : null;
  }

  @override
  Future<List<SmsMessage>> getMessagesByThread(String threadId) async {
    final query = _db.select(_db.messages)
      ..where((tbl) => tbl.threadId.equals(threadId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.asc),
      ]);

    final rows = await query.get();
    final messageIds = rows.map((r) => r.id).toList();
    final labelsMap = await _getLabelsForMessages(messageIds);

    return rows.map((r) => _mapRowToMessage(r, labelsMap[r.id] ?? [])).toList();
  }

  @override
  Future<List<SmsMessage>> getAllMessages() async {
    final rows = await _db.select(_db.messages).get();
    final labelsMap = await _getLabelsForMessages(
      rows.map((r) => r.id).toList(),
    );
    return rows.map((r) => _mapRowToMessage(r, labelsMap[r.id] ?? [])).toList();
  }

  @override
  Future<int> getMessageCount() async {
    final countExp = _db.messages.id.count();
    final query = _db.selectOnly(_db.messages)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  @override
  Future<List<SmsMessage>> getMessagesPaged({
    required int limit,
    required int offset,
  }) async {
    final query = _db.select(_db.messages)
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);
    final rows = await query.get();
    final messageIds = rows.map((r) => r.id).toList();
    final labelsMap = await _getLabelsForMessages(messageIds);
    return rows.map((r) => _mapRowToMessage(r, labelsMap[r.id] ?? [])).toList();
  }

  @override
  Future<void> insertMessage(SmsMessage message) async {
    await _db.transaction(() async {
      await _db
          .into(_db.messages)
          .insertOnConflictUpdate(_messageToCompanion(message));

      if (message.labels.isNotEmpty) {
        for (final label in message.labels) {
          await _db
              .into(_db.messageLabels)
              .insertOnConflictUpdate(
                MessageLabelsCompanion(
                  messageId: Value(message.id),
                  labelId: Value(label.id),
                ),
              );
        }
      }
    });
  }

  @override
  Future<void> insertMessages(List<SmsMessage> messages) async {
    if (messages.isEmpty) return;
    await _db.transaction(() async {
      for (final msg in messages) {
        await insertMessage(msg);
      }
    });
  }

  @override
  Future<void> markRead(String id) => markReadMany([id]);

  @override
  Future<void> markReadMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isRead: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> markUnread(String id) => markUnreadMany([id]);

  @override
  Future<void> markUnreadMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isRead: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> star(String id) => starMany([id]);

  @override
  Future<void> starMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isStarred: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> unstar(String id) => unstarMany([id]);

  @override
  Future<void> unstarMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isStarred: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> pin(String id) => pinMany([id]);

  @override
  Future<void> pinMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isPinned: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> unpin(String id) => unpinMany([id]);

  @override
  Future<void> unpinMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isPinned: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> archive(String id) => archiveMany([id]);

  @override
  Future<void> archiveMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isArchived: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> unarchive(String id) => unarchiveMany([id]);

  @override
  Future<void> unarchiveMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isArchived: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> softDelete(String id) => softDeleteMany([id]);

  @override
  Future<void> softDeleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> restore(String id) => restoreMany([id]);

  @override
  Future<void> restoreMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.update(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).write(
        MessagesCompanion(
          isDeleted: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Future<void> permanentDelete(String id) => permanentDeleteMany([id]);

  @override
  Future<void> permanentDeleteMany(List<String> ids) async {
    if (ids.isEmpty) return;
    await _db.transaction(() async {
      await (_db.delete(
        _db.messages,
      )..where((tbl) => tbl.id.isIn(ids) | tbl.threadId.isIn(ids))).go();
    });
  }

  @override
  Stream<SmsConversation?> watchConversation(String conversationId) {
    final query = _db.select(_db.messages)
      ..where(
        (tbl) =>
            (tbl.threadId.equals(conversationId) | tbl.id.equals(conversationId)) &
            tbl.isDeleted.equals(false),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.asc),
      ]);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) {
        // Fallback: check if conversation exists even if deleted or without active filter
        final fallbackQuery = _db.select(_db.messages)
          ..where(
            (tbl) =>
                tbl.threadId.equals(conversationId) | tbl.id.equals(conversationId),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.asc),
          ]);
        final fallbackRows = await fallbackQuery.get();
        if (fallbackRows.isEmpty) return null;
        final convs = await _groupToConversations(fallbackRows);
        return convs.isNotEmpty ? convs.first : null;
      }
      final conversations = await _groupToConversations(rows);
      return conversations.isNotEmpty ? conversations.first : null;
    });
  }

  @override
  Future<void> starMessage(String messageId) async {
    await (_db.update(_db.messages)..where((tbl) => tbl.id.equals(messageId))).write(
      MessagesCompanion(
        isStarred: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> unstarMessage(String messageId) async {
    await (_db.update(_db.messages)..where((tbl) => tbl.id.equals(messageId))).write(
      MessagesCompanion(
        isStarred: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await (_db.update(_db.messages)..where((tbl) => tbl.id.equals(messageId))).write(
      MessagesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> markMessageRead(String messageId) async {
    await (_db.update(_db.messages)..where((tbl) => tbl.id.equals(messageId))).write(
      MessagesCompanion(
        isRead: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // --- Helpers ---

  Stream<List<SmsConversation>> _buildConversationStream(
    SimpleSelectStatement<$MessagesTable, Message> query,
  ) {
    return query.watch().asyncMap(
      (rawMessages) => _groupToConversations(rawMessages),
    );
  }

  Future<List<SmsConversation>> _groupToConversations(
    List<Message> rawMessages,
  ) async {
    if (rawMessages.isEmpty) return [];

    final messageIds = rawMessages.map((r) => r.id).toList();
    final labelsMap = await _getLabelsForMessages(messageIds);

    // Group messages by threadId
    final grouped = <String, List<Message>>{};
    for (final m in rawMessages) {
      grouped.putIfAbsent(m.threadId, () => []).add(m);
    }

    final conversations = <SmsConversation>[];

    for (final entry in grouped.entries) {
      final threadId = entry.key;
      final threadRows = entry.value;

      // Sort thread messages newest first
      threadRows.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

      final latestRow = threadRows.first;
      final domainMessages = threadRows
          .map((r) => _mapRowToMessage(r, labelsMap[r.id] ?? []))
          .toList();

      final category = CategoryTypeExtension.fromString(latestRow.category);
      final senderDisplayName =
          latestRow.brandName ?? latestRow.brand ?? latestRow.sender;

      final allLabels = <LabelModel>{};
      for (final msg in domainMessages) {
        allLabels.addAll(msg.labels);
      }

      final isStarred = threadRows.any((m) => m.isStarred);
      final isPinned = threadRows.any((m) => m.isPinned);
      final isArchived = threadRows.every((m) => m.isArchived);
      final isDeleted = threadRows.every((m) => m.isDeleted);

      conversations.add(
        SmsConversation(
          id: threadId,
          sender: latestRow.sender,
          senderDisplayName: senderDisplayName,
          category: category,
          messages: domainMessages,
          isStarred: isStarred,
          isPinned: isPinned,
          isArchived: isArchived,
          isDeleted: isDeleted,
          labels: allLabels.toList(),
        ),
      );
    }

    // Sort conversations: Pinned first, then newest timestamp
    conversations.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.latestTimestamp.compareTo(a.latestTimestamp);
    });

    return conversations;
  }

  Future<List<LabelModel>> _getLabelsForMessage(String messageId) async {
    final query = _db.select(_db.messageLabels).join([
      innerJoin(_db.labels, _db.labels.id.equalsExp(_db.messageLabels.labelId)),
    ])..where(_db.messageLabels.messageId.equals(messageId));

    final rows = await query.get();
    return rows.map((r) {
      final l = r.readTable(_db.labels);
      return LabelModel(
        id: l.id,
        name: l.name,
        colorValue: l.colorValue,
        iconCode: l.iconCode,
        createdAt: l.createdAt,
        updatedAt: l.updatedAt,
      );
    }).toList();
  }

  Future<Map<String, List<LabelModel>>> _getLabelsForMessages(
    List<String> messageIds,
  ) async {
    if (messageIds.isEmpty) return {};

    final query = _db.select(_db.messageLabels).join([
      innerJoin(_db.labels, _db.labels.id.equalsExp(_db.messageLabels.labelId)),
    ])..where(_db.messageLabels.messageId.isIn(messageIds));

    final rows = await query.get();
    final result = <String, List<LabelModel>>{};

    for (final r in rows) {
      final msgRel = r.readTable(_db.messageLabels);
      final l = r.readTable(_db.labels);
      final label = LabelModel(
        id: l.id,
        name: l.name,
        colorValue: l.colorValue,
        iconCode: l.iconCode,
        createdAt: l.createdAt,
        updatedAt: l.updatedAt,
      );
      result.putIfAbsent(msgRel.messageId, () => []).add(label);
    }

    return result;
  }

  SmsMessage _mapRowToMessage(Message row, List<LabelModel> labels) {
    return SmsMessage(
      id: row.id,
      threadId: row.threadId,
      sender: row.sender,
      rawSender: row.rawSender ?? row.sender,
      normalizedSender: row.normalizedSender,
      header: row.header,
      brand: row.brand,
      brandNameField: row.brandName,
      body: row.body,
      receivedAt: row.receivedAt,
      category: CategoryTypeExtension.fromString(row.category),
      classificationConfidence: row.classificationConfidence,
      classificationReason: ClassificationReason.fromString(
        row.classificationReason,
      ),
      reasonDescription: row.classificationReason,
      isRead: row.isRead,
      isStarred: row.isStarred,
      isPinned: row.isPinned,
      isArchived: row.isArchived,
      isDeleted: row.isDeleted,
      otp: row.otp,
      operatorPrefix: row.operatorPrefix,
      parsedHeader: row.parsedHeader,
      messageTypeSuffix: row.messageTypeSuffix,
      classificationVersion: row.classificationVersion,
      labels: labels,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  MessagesCompanion _messageToCompanion(SmsMessage m) {
    return MessagesCompanion(
      id: Value(m.id),
      threadId: Value(m.threadId),
      sender: Value(m.sender),
      rawSender: Value(m.rawSender ?? m.sender),
      normalizedSender: Value(m.normalizedSender),
      header: Value(m.header),
      brand: Value(m.brand),
      brandName: Value(m.brandNameField ?? m.brand),
      body: Value(m.body),
      receivedAt: Value(m.receivedAt),
      category: Value(m.category.name),
      classificationConfidence: Value(m.classificationConfidence),
      classificationReason: Value(m.effectiveReasonDescription),
      isRead: Value(m.isRead),
      isStarred: Value(m.isStarred),
      isPinned: Value(m.isPinned),
      isArchived: Value(m.isArchived),
      isDeleted: Value(m.isDeleted),
      otp: Value(m.otp),
      operatorPrefix: Value(m.operatorPrefix),
      parsedHeader: Value(m.parsedHeader),
      messageTypeSuffix: Value(m.messageTypeSuffix),
      classificationVersion: Value(m.classificationVersion),
      createdAt: Value(m.createdAt),
      updatedAt: Value(m.updatedAt),
    );
  }
}

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  throw UnimplementedError();
});
