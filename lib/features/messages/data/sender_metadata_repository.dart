import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/messages/domain/sender_metadata.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SenderMetadataRepository {
  Future<void> upsertMetadata(SenderMetadata metadata);
  Future<void> upsertAll(List<SenderMetadata> metadataList);
  Future<SenderMetadata?> getMetadataForHeader(String header);
  Future<List<SenderMetadata>> getAllMetadata();
  Future<void> deleteMetadata(String id);
}

class DriftSenderMetadataRepository implements SenderMetadataRepository {
  final AppDatabase _db;

  DriftSenderMetadataRepository(this._db);

  @override
  Future<void> upsertMetadata(SenderMetadata metadata) async {
    await _db
        .into(_db.senderMetadataTable)
        .insertOnConflictUpdate(
          SenderMetadataTableCompanion(
            id: Value(metadata.id),
            header: Value(metadata.header.toUpperCase().trim()),
            brand: Value(metadata.brand),
            organization: Value(metadata.organization),
            industry: Value(metadata.industry),
            metadataVersion: Value(metadata.metadataVersion),
            updatedAt: Value(metadata.updatedAt),
          ),
        );
  }

  @override
  Future<void> upsertAll(List<SenderMetadata> metadataList) async {
    await _db.transaction(() async {
      for (final meta in metadataList) {
        await upsertMetadata(meta);
      }
    });
  }

  @override
  Future<SenderMetadata?> getMetadataForHeader(String header) async {
    final cleanHeader = header.toUpperCase().trim();
    final query = _db.select(_db.senderMetadataTable)
      ..where((tbl) => tbl.header.equals(cleanHeader));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToEntity(row);
  }

  @override
  Future<List<SenderMetadata>> getAllMetadata() async {
    final rows = await _db.select(_db.senderMetadataTable).get();
    return rows.map(_mapRowToEntity).toList();
  }

  @override
  Future<void> deleteMetadata(String id) async {
    await (_db.delete(
      _db.senderMetadataTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  SenderMetadata _mapRowToEntity(SenderMetadataTableData row) {
    return SenderMetadata(
      id: row.id,
      header: row.header,
      brand: row.brand,
      organization: row.organization,
      industry: row.industry,
      metadataVersion: row.metadataVersion,
      updatedAt: row.updatedAt,
    );
  }
}

final senderMetadataRepositoryProvider = Provider<SenderMetadataRepository>((
  ref,
) {
  // Provided from AppDatabase
  throw UnimplementedError();
});
