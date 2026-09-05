import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/labels/data/label_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftLabelRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftLabelRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('LabelRepository Tests', () {
    test('creates, retrieves, renames, and deletes a label', () async {
      final label = await repo.createLabel(name: 'Finance');
      expect(label.name, 'Finance');

      var list = await repo.getLabels();
      expect(list.length, 1);
      expect(list.first.id, label.id);

      // Rename
      await repo.renameLabel(label.id, 'Banking & Finance');
      final fetched = await repo.getLabelById(label.id);
      expect(fetched?.name, 'Banking & Finance');

      // Delete
      await repo.deleteLabel(label.id);
      list = await repo.getLabels();
      expect(list, isEmpty);
    });

    test('assigns and removes labels for multiple messages', () async {
      final now = DateTime(2026, 9, 1);

      // Insert messages first to satisfy foreign key constraints
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              id: 'msg_1',
              threadId: 't1',
              sender: 'SENDER1',
              header: 'SENDER1',
              body: 'Body 1',
              receivedAt: now,
              category: CategoryType.transactional.name,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              id: 'msg_2',
              threadId: 't2',
              sender: 'SENDER2',
              header: 'SENDER2',
              body: 'Body 2',
              receivedAt: now,
              category: CategoryType.service.name,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final l1 = await repo.createLabel(name: 'OTPs');
      final l2 = await repo.createLabel(name: 'Alerts');

      // Assign both labels to msg_1 and msg_2
      await repo.assignLabels(['msg_1', 'msg_2'], [l1.id, l2.id]);

      final msg1Labels = await repo.getLabelsForMessage('msg_1');
      expect(msg1Labels.length, 2);
      expect(msg1Labels.map((l) => l.name), containsAll(['OTPs', 'Alerts']));

      // Remove l1 from msg_1
      await repo.removeLabels(['msg_1'], [l1.id]);
      final remaining = await repo.getLabelsForMessage('msg_1');
      expect(remaining.length, 1);
      expect(remaining.first.id, l2.id);
    });
  });
}
