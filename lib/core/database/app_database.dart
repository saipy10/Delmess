import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Messages, Labels, MessageLabels, SenderMetadataTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Enable foreign keys in SQLite
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(messages, messages.operatorPrefix);
        await m.addColumn(messages, messages.parsedHeader);
        await m.addColumn(messages, messages.messageTypeSuffix);
        await m.addColumn(messages, messages.classificationVersion);
      }
      if (from < 3) {
        await m.addColumn(messages, messages.rawSender);
        await m.addColumn(messages, messages.normalizedSender);
        await m.addColumn(messages, messages.brandName);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return NativeDatabase.memory();
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'delmess_sms.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
