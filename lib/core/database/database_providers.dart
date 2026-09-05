import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/labels/data/label_repository.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Database instance provider
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Override the message repository provider with Drift implementation
final driftMessageRepositoryProvider = Provider<MessageRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftMessageRepository(db);
});

/// Override the label repository provider with Drift implementation
final driftLabelRepositoryProvider = Provider<LabelRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftLabelRepository(db);
});

/// Override the sender metadata repository provider with Drift implementation
final driftSenderMetadataRepositoryProvider =
    Provider<SenderMetadataRepository>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return DriftSenderMetadataRepository(db);
    });
