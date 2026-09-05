import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftMessageRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftMessageRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MessageRepository Operations & Bulk Tests', () {
    final now = DateTime(2026, 9, 1, 10, 0, 0);

    final msgA = SmsMessage(
      id: 'msg_a',
      threadId: 'thread_a',
      sender: 'HDFC',
      header: 'HDFC',
      body: 'Message A',
      receivedAt: now,
      category: CategoryType.transactional,
      isRead: false,
      isStarred: false,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
    );

    final msgB = SmsMessage(
      id: 'msg_b',
      threadId: 'thread_b',
      sender: 'SWIGGY',
      header: 'SWIGGY',
      body: 'Message B',
      receivedAt: now.add(const Duration(minutes: 1)),
      category: CategoryType.service,
      isRead: false,
      isStarred: false,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
    );

    final msgC = SmsMessage(
      id: 'msg_c',
      threadId: 'thread_c',
      sender: 'AMAZON',
      header: 'AMAZON',
      body: 'Message C',
      receivedAt: now.add(const Duration(minutes: 2)),
      category: CategoryType.promotional,
      isRead: true,
      isStarred: true,
      isPinned: false,
      createdAt: now,
      updatedAt: now,
    );

    test('insertMessages stores multiple messages and retrieves all', () async {
      await repo.insertMessages([msgA, msgB, msgC]);

      final all = await repo.getAllMessages();
      expect(all.length, 3);
      expect(all.map((m) => m.id), containsAll(['msg_a', 'msg_b', 'msg_c']));
    });

    test('markReadMany updates unread items to read in transaction', () async {
      await repo.insertMessages([msgA, msgB, msgC]);

      await repo.markReadMany(['msg_a', 'msg_b', 'msg_c']);

      final a = await repo.getMessageById('msg_a');
      final b = await repo.getMessageById('msg_b');
      final c = await repo.getMessageById('msg_c');

      expect(a?.isRead, isTrue);
      expect(b?.isRead, isTrue);
      expect(c?.isRead, isTrue);
    });

    test('starMany and unstarMany bulk toggles', () async {
      await repo.insertMessages([msgA, msgB, msgC]);

      await repo.starMany(['msg_a', 'msg_b']);
      var a = await repo.getMessageById('msg_a');
      var b = await repo.getMessageById('msg_b');
      expect(a?.isStarred, isTrue);
      expect(b?.isStarred, isTrue);

      await repo.unstarMany(['msg_a', 'msg_b', 'msg_c']);
      a = await repo.getMessageById('msg_a');
      b = await repo.getMessageById('msg_b');
      final c = await repo.getMessageById('msg_c');
      expect(a?.isStarred, isFalse);
      expect(b?.isStarred, isFalse);
      expect(c?.isStarred, isFalse);
    });

    test('pinMany and unpinMany bulk operations', () async {
      await repo.insertMessages([msgA, msgB]);

      await repo.pinMany(['msg_a', 'msg_b']);
      var a = await repo.getMessageById('msg_a');
      var b = await repo.getMessageById('msg_b');
      expect(a?.isPinned, isTrue);
      expect(b?.isPinned, isTrue);

      await repo.unpinMany(['msg_a', 'msg_b']);
      a = await repo.getMessageById('msg_a');
      b = await repo.getMessageById('msg_b');
      expect(a?.isPinned, isFalse);
      expect(b?.isPinned, isFalse);
    });

    test('archiveMany and unarchiveMany bulk operations', () async {
      await repo.insertMessages([msgA, msgB]);

      await repo.archiveMany(['msg_a', 'msg_b']);
      var a = await repo.getMessageById('msg_a');
      var b = await repo.getMessageById('msg_b');
      expect(a?.isArchived, isTrue);
      expect(b?.isArchived, isTrue);

      await repo.unarchiveMany(['msg_a']);
      a = await repo.getMessageById('msg_a');
      b = await repo.getMessageById('msg_b');
      expect(a?.isArchived, isFalse);
      expect(b?.isArchived, isTrue);
    });

    test('softDeleteMany, restoreMany, and permanentDeleteMany', () async {
      await repo.insertMessages([msgA, msgB, msgC]);

      // Soft delete
      await repo.softDeleteMany(['msg_a', 'msg_b']);
      var a = await repo.getMessageById('msg_a');
      var b = await repo.getMessageById('msg_b');
      var c = await repo.getMessageById('msg_c');
      expect(a?.isDeleted, isTrue);
      expect(b?.isDeleted, isTrue);
      expect(c?.isDeleted, isFalse);

      // Restore
      await repo.restoreMany(['msg_a']);
      a = await repo.getMessageById('msg_a');
      expect(a?.isDeleted, isFalse);

      // Permanent delete
      await repo.permanentDeleteMany(['msg_b']);
      b = await repo.getMessageById('msg_b');
      expect(b, isNull);
    });

    test('thread grouping groups messages into SmsConversation', () async {
      final threadMsg1 = msgA.copyWith(
        id: 'msg_t1',
        threadId: 'thread_xyz',
        receivedAt: now,
      );
      final threadMsg2 = msgA.copyWith(
        id: 'msg_t2',
        threadId: 'thread_xyz',
        receivedAt: now.add(const Duration(minutes: 5)),
      );

      await repo.insertMessages([threadMsg1, threadMsg2]);

      final conv = await repo.getConversationById('thread_xyz');
      expect(conv, isNotNull);
      expect(conv?.id, 'thread_xyz');
      expect(conv?.messages.length, 2);
      expect(conv?.latestMessage.id, 'msg_t2'); // newest first
    });
  });
}
