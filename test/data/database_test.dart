import 'package:delmess/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Database & Cascade Tests', () {
    final now = DateTime(2026, 9, 1, 10, 0, 0);

    test('inserts and retrieves messages from Messages table', () async {
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion(
              id: const Value('m1'),
              threadId: const Value('t1'),
              sender: const Value('AD-HDFCBK-T'),
              header: const Value('HDFCBK'),
              body: const Value('Your OTP is 123456'),
              receivedAt: Value(now),
              category: const Value('transactional'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final rows = await db.select(db.messages).get();
      expect(rows.length, 1);
      expect(rows.first.id, 'm1');
      expect(rows.first.sender, 'AD-HDFCBK-T');
      expect(rows.first.isRead, isFalse);
    });

    test('cascade deletes message_labels when message is deleted', () async {
      // 1. Insert message
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion(
              id: const Value('m1'),
              threadId: const Value('t1'),
              sender: const Value('HDFC'),
              header: const Value('HDFC'),
              body: const Value('Alert'),
              receivedAt: Value(now),
              category: const Value('transactional'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 2. Insert label
      await db
          .into(db.labels)
          .insert(
            LabelsCompanion(
              id: const Value('l1'),
              name: const Value('Banking'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      // 3. Link message & label
      await db
          .into(db.messageLabels)
          .insert(
            const MessageLabelsCompanion(
              messageId: Value('m1'),
              labelId: Value('l1'),
            ),
          );

      var rels = await db.select(db.messageLabels).get();
      expect(rels.length, 1);

      // 4. Delete the message
      await (db.delete(db.messages)..where((t) => t.id.equals('m1'))).go();

      // 5. Verify message_labels was cascade cleaned
      rels = await db.select(db.messageLabels).get();
      expect(rels.length, 0);

      // Label itself should still exist
      final labelRows = await db.select(db.labels).get();
      expect(labelRows.length, 1);
    });

    test('deleting a label does NOT delete messages', () async {
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion(
              id: const Value('m2'),
              threadId: const Value('t2'),
              sender: const Value('AMAZON'),
              header: const Value('AMAZON'),
              body: const Value('Package dispatched'),
              receivedAt: Value(now),
              category: const Value('service'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      await db
          .into(db.labels)
          .insert(
            LabelsCompanion(
              id: const Value('l2'),
              name: const Value('Deliveries'),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      await db
          .into(db.messageLabels)
          .insert(
            const MessageLabelsCompanion(
              messageId: Value('m2'),
              labelId: Value('l2'),
            ),
          );

      // Delete the label
      await (db.delete(db.labels)..where((t) => t.id.equals('l2'))).go();

      // Relationship is removed
      final rels = await db.select(db.messageLabels).get();
      expect(rels.length, 0);

      // Message still remains!
      final messages = await db.select(db.messages).get();
      expect(messages.length, 1);
      expect(messages.first.id, 'm2');
    });

    test('transaction rolls back on failure', () async {
      try {
        await db.transaction(() async {
          await db
              .into(db.messages)
              .insert(
                MessagesCompanion(
                  id: const Value('m_tx_1'),
                  threadId: const Value('t_tx'),
                  sender: const Value('HDFC'),
                  header: const Value('HDFC'),
                  body: const Value('Tx message 1'),
                  receivedAt: Value(now),
                  category: const Value('transactional'),
                  createdAt: Value(now),
                  updatedAt: Value(now),
                ),
              );

          // Force an exception to simulate failure
          throw Exception('Simulated database error during transaction');
        });
      } catch (_) {
        // Expected
      }

      // Verify rollback: m_tx_1 should NOT exist in database
      final rows = await db.select(db.messages).get();
      expect(rows.length, 0);
    });
  });
}
