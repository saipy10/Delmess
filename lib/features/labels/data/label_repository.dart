import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

abstract class LabelRepository {
  Stream<List<LabelModel>> watchLabels();
  Future<List<LabelModel>> getLabels();
  Future<LabelModel?> getLabelById(String id);
  Future<LabelModel> createLabel({
    required String name,
    int? colorValue,
    int? iconCode,
  });
  Future<void> renameLabel(String id, String newName);
  Future<void> updateLabel(LabelModel label);
  Future<void> deleteLabel(String id);
  Future<List<LabelModel>> getLabelsForMessage(String messageId);
  Future<Map<String, List<LabelModel>>> getLabelsForMessages(
    List<String> messageIds,
  );
  Future<void> assignLabels(List<String> messageIds, List<String> labelIds);
  Future<void> removeLabels(List<String> messageIds, List<String> labelIds);
}

class DriftLabelRepository implements LabelRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  DriftLabelRepository(this._db);

  @override
  Stream<List<LabelModel>> watchLabels() {
    return _db.select(_db.labels).watch().asyncMap((labels) async {
      final relations = await _db.select(_db.messageLabels).get();
      final counts = <String, int>{};
      for (final rel in relations) {
        counts[rel.labelId] = (counts[rel.labelId] ?? 0) + 1;
      }
      return labels
          .map(
            (row) => LabelModel(
              id: row.id,
              name: row.name,
              colorValue: row.colorValue,
              iconCode: row.iconCode,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
              messageCount: counts[row.id] ?? 0,
            ),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Future<List<LabelModel>> getLabels() async {
    final labels = await _db.select(_db.labels).get();
    final relations = await _db.select(_db.messageLabels).get();
    final counts = <String, int>{};
    for (final rel in relations) {
      counts[rel.labelId] = (counts[rel.labelId] ?? 0) + 1;
    }
    return labels
        .map(
          (row) => LabelModel(
            id: row.id,
            name: row.name,
            colorValue: row.colorValue,
            iconCode: row.iconCode,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            messageCount: counts[row.id] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<LabelModel?> getLabelById(String id) async {
    final query = _db.select(_db.labels)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final relations = await (_db.select(
      _db.messageLabels,
    )..where((tbl) => tbl.labelId.equals(id))).get();

    return LabelModel(
      id: row.id,
      name: row.name,
      colorValue: row.colorValue,
      iconCode: row.iconCode,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      messageCount: relations.length,
    );
  }

  @override
  Future<LabelModel> createLabel({
    required String name,
    int? colorValue,
    int? iconCode,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final companion = LabelsCompanion(
      id: Value(id),
      name: Value(name.trim()),
      colorValue: colorValue != null ? Value(colorValue) : const Value.absent(),
      iconCode: iconCode != null ? Value(iconCode) : const Value.absent(),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.into(_db.labels).insert(companion);

    return LabelModel(
      id: id,
      name: name.trim(),
      colorValue: colorValue ?? 0xFF6750A4,
      iconCode: iconCode ?? 0xe362,
      createdAt: now,
      updatedAt: now,
      messageCount: 0,
    );
  }

  @override
  Future<void> renameLabel(String id, String newName) async {
    await (_db.update(_db.labels)..where((tbl) => tbl.id.equals(id))).write(
      LabelsCompanion(
        name: Value(newName.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateLabel(LabelModel label) async {
    await (_db.update(
      _db.labels,
    )..where((tbl) => tbl.id.equals(label.id))).write(
      LabelsCompanion(
        name: Value(label.name.trim()),
        colorValue: Value(label.colorValue),
        iconCode: Value(label.iconCode),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteLabel(String id) async {
    await (_db.delete(_db.labels)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<List<LabelModel>> getLabelsForMessage(String messageId) async {
    final query = _db.select(_db.messageLabels).join([
      innerJoin(_db.labels, _db.labels.id.equalsExp(_db.messageLabels.labelId)),
    ])..where(_db.messageLabels.messageId.equals(messageId));

    final rows = await query.get();
    return rows.map((r) {
      final labelRow = r.readTable(_db.labels);
      return LabelModel(
        id: labelRow.id,
        name: labelRow.name,
        colorValue: labelRow.colorValue,
        iconCode: labelRow.iconCode,
        createdAt: labelRow.createdAt,
        updatedAt: labelRow.updatedAt,
      );
    }).toList();
  }

  @override
  Future<Map<String, List<LabelModel>>> getLabelsForMessages(
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
      final labelRow = r.readTable(_db.labels);
      final label = LabelModel(
        id: labelRow.id,
        name: labelRow.name,
        colorValue: labelRow.colorValue,
        iconCode: labelRow.iconCode,
        createdAt: labelRow.createdAt,
        updatedAt: labelRow.updatedAt,
      );
      result.putIfAbsent(msgRel.messageId, () => []).add(label);
    }

    return result;
  }

  @override
  Future<void> assignLabels(
    List<String> messageIds,
    List<String> labelIds,
  ) async {
    if (messageIds.isEmpty || labelIds.isEmpty) return;

    await _db.transaction(() async {
      for (final msgId in messageIds) {
        for (final lblId in labelIds) {
          await _db
              .into(_db.messageLabels)
              .insertOnConflictUpdate(
                MessageLabelsCompanion(
                  messageId: Value(msgId),
                  labelId: Value(lblId),
                ),
              );
        }
      }
    });
  }

  @override
  Future<void> removeLabels(
    List<String> messageIds,
    List<String> labelIds,
  ) async {
    if (messageIds.isEmpty || labelIds.isEmpty) return;

    await _db.transaction(() async {
      for (final msgId in messageIds) {
        for (final lblId in labelIds) {
          await (_db.delete(_db.messageLabels)..where(
                (tbl) =>
                    tbl.messageId.equals(msgId) & tbl.labelId.equals(lblId),
              ))
              .go();
        }
      }
    });
  }
}

final labelRepositoryProvider = Provider<LabelRepository>((ref) {
  throw UnimplementedError();
});
