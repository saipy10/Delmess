import 'package:drift/drift.dart';

/// Messages table storing raw & normalized SMS data.
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get threadId => text()();
  TextColumn get sender => text()();
  TextColumn get header => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get body => text()();
  DateTimeColumn get receivedAt => dateTime()();
  TextColumn get category => text()();
  RealColumn get classificationConfidence =>
      real().withDefault(const Constant(1.0))();
  TextColumn get classificationReason =>
      text().withDefault(const Constant('unknown'))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get otp => text().nullable()();
  TextColumn get operatorPrefix => text().nullable()();
  TextColumn get parsedHeader => text().nullable()();
  TextColumn get messageTypeSuffix => text().nullable()();
  TextColumn get rawSender => text().nullable()();
  TextColumn get normalizedSender => text().nullable()();
  TextColumn get brandName => text().nullable()();
  IntColumn get classificationVersion =>
      integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  List<TableIndex> get indexes => [
    TableIndex(name: 'idx_messages_thread_id', columns: {threadId}),
    TableIndex(name: 'idx_messages_sender', columns: {sender}),
    TableIndex(name: 'idx_messages_header', columns: {header}),
    TableIndex(name: 'idx_messages_brand', columns: {brand}),
    TableIndex(name: 'idx_messages_received_at', columns: {receivedAt}),
    TableIndex(name: 'idx_messages_category', columns: {category}),
    TableIndex(name: 'idx_messages_is_read', columns: {isRead}),
    TableIndex(name: 'idx_messages_is_starred', columns: {isStarred}),
    TableIndex(name: 'idx_messages_is_pinned', columns: {isPinned}),
    TableIndex(name: 'idx_messages_is_archived', columns: {isArchived}),
    TableIndex(name: 'idx_messages_is_deleted', columns: {isDeleted}),
    TableIndex(
      name: 'idx_messages_inbox_query',
      columns: {isDeleted, isArchived, isPinned, receivedAt},
    ),
  ];
}

/// Labels table storing tag metadata.
class Labels extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  IntColumn get colorValue =>
      integer().withDefault(const Constant(0xFF6750A4))();
  IntColumn get iconCode => integer().withDefault(const Constant(0xe362))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Many-to-many relationship table between Messages and Labels.
class MessageLabels extends Table {
  TextColumn get messageId =>
      text().references(Messages, #id, onDelete: KeyAction.cascade)();
  TextColumn get labelId =>
      text().references(Labels, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {messageId, labelId};

  List<TableIndex> get indexes => [
    TableIndex(name: 'idx_msg_labels_label_id', columns: {labelId}),
    TableIndex(name: 'idx_msg_labels_msg_id', columns: {messageId}),
  ];
}

/// Sender Metadata table for recognized headers (e.g. HDFCBK -> HDFC Bank).
class SenderMetadataTable extends Table {
  TextColumn get id => text()();
  TextColumn get header => text().unique()();
  TextColumn get brand => text()();
  TextColumn get organization => text()();
  TextColumn get industry => text()();
  IntColumn get metadataVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  List<TableIndex> get indexes => [
    TableIndex(name: 'idx_sender_meta_header', columns: {header}),
  ];
}
