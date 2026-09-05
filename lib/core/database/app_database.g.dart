// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _threadIdMeta = const VerificationMeta(
    'threadId',
  );
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
    'thread_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headerMeta = const VerificationMeta('header');
  @override
  late final GeneratedColumn<String> header = GeneratedColumn<String>(
    'header',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classificationConfidenceMeta =
      const VerificationMeta('classificationConfidence');
  @override
  late final GeneratedColumn<double> classificationConfidence =
      GeneratedColumn<double>(
        'classification_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _classificationReasonMeta =
      const VerificationMeta('classificationReason');
  @override
  late final GeneratedColumn<String> classificationReason =
      GeneratedColumn<String>(
        'classification_reason',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('unknown'),
      );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _otpMeta = const VerificationMeta('otp');
  @override
  late final GeneratedColumn<String> otp = GeneratedColumn<String>(
    'otp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operatorPrefixMeta = const VerificationMeta(
    'operatorPrefix',
  );
  @override
  late final GeneratedColumn<String> operatorPrefix = GeneratedColumn<String>(
    'operator_prefix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parsedHeaderMeta = const VerificationMeta(
    'parsedHeader',
  );
  @override
  late final GeneratedColumn<String> parsedHeader = GeneratedColumn<String>(
    'parsed_header',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageTypeSuffixMeta = const VerificationMeta(
    'messageTypeSuffix',
  );
  @override
  late final GeneratedColumn<String> messageTypeSuffix =
      GeneratedColumn<String>(
        'message_type_suffix',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _rawSenderMeta = const VerificationMeta(
    'rawSender',
  );
  @override
  late final GeneratedColumn<String> rawSender = GeneratedColumn<String>(
    'raw_sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _normalizedSenderMeta = const VerificationMeta(
    'normalizedSender',
  );
  @override
  late final GeneratedColumn<String> normalizedSender = GeneratedColumn<String>(
    'normalized_sender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classificationVersionMeta =
      const VerificationMeta('classificationVersion');
  @override
  late final GeneratedColumn<int> classificationVersion = GeneratedColumn<int>(
    'classification_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    threadId,
    sender,
    header,
    brand,
    body,
    receivedAt,
    category,
    classificationConfidence,
    classificationReason,
    isRead,
    isStarred,
    isPinned,
    isArchived,
    isDeleted,
    otp,
    operatorPrefix,
    parsedHeader,
    messageTypeSuffix,
    rawSender,
    normalizedSender,
    brandName,
    classificationVersion,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(
        _threadIdMeta,
        threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('header')) {
      context.handle(
        _headerMeta,
        header.isAcceptableOrUnknown(data['header']!, _headerMeta),
      );
    } else if (isInserting) {
      context.missing(_headerMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('classification_confidence')) {
      context.handle(
        _classificationConfidenceMeta,
        classificationConfidence.isAcceptableOrUnknown(
          data['classification_confidence']!,
          _classificationConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('classification_reason')) {
      context.handle(
        _classificationReasonMeta,
        classificationReason.isAcceptableOrUnknown(
          data['classification_reason']!,
          _classificationReasonMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('otp')) {
      context.handle(
        _otpMeta,
        otp.isAcceptableOrUnknown(data['otp']!, _otpMeta),
      );
    }
    if (data.containsKey('operator_prefix')) {
      context.handle(
        _operatorPrefixMeta,
        operatorPrefix.isAcceptableOrUnknown(
          data['operator_prefix']!,
          _operatorPrefixMeta,
        ),
      );
    }
    if (data.containsKey('parsed_header')) {
      context.handle(
        _parsedHeaderMeta,
        parsedHeader.isAcceptableOrUnknown(
          data['parsed_header']!,
          _parsedHeaderMeta,
        ),
      );
    }
    if (data.containsKey('message_type_suffix')) {
      context.handle(
        _messageTypeSuffixMeta,
        messageTypeSuffix.isAcceptableOrUnknown(
          data['message_type_suffix']!,
          _messageTypeSuffixMeta,
        ),
      );
    }
    if (data.containsKey('raw_sender')) {
      context.handle(
        _rawSenderMeta,
        rawSender.isAcceptableOrUnknown(data['raw_sender']!, _rawSenderMeta),
      );
    }
    if (data.containsKey('normalized_sender')) {
      context.handle(
        _normalizedSenderMeta,
        normalizedSender.isAcceptableOrUnknown(
          data['normalized_sender']!,
          _normalizedSenderMeta,
        ),
      );
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    }
    if (data.containsKey('classification_version')) {
      context.handle(
        _classificationVersionMeta,
        classificationVersion.isAcceptableOrUnknown(
          data['classification_version']!,
          _classificationVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      threadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thread_id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      header: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      classificationConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}classification_confidence'],
      )!,
      classificationReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}classification_reason'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      otp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}otp'],
      ),
      operatorPrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_prefix'],
      ),
      parsedHeader: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parsed_header'],
      ),
      messageTypeSuffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_type_suffix'],
      ),
      rawSender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sender'],
      ),
      normalizedSender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_sender'],
      ),
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      ),
      classificationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}classification_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String threadId;
  final String sender;
  final String header;
  final String? brand;
  final String body;
  final DateTime receivedAt;
  final String category;
  final double classificationConfidence;
  final String classificationReason;
  final bool isRead;
  final bool isStarred;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final String? otp;
  final String? operatorPrefix;
  final String? parsedHeader;
  final String? messageTypeSuffix;
  final String? rawSender;
  final String? normalizedSender;
  final String? brandName;
  final int classificationVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Message({
    required this.id,
    required this.threadId,
    required this.sender,
    required this.header,
    this.brand,
    required this.body,
    required this.receivedAt,
    required this.category,
    required this.classificationConfidence,
    required this.classificationReason,
    required this.isRead,
    required this.isStarred,
    required this.isPinned,
    required this.isArchived,
    required this.isDeleted,
    this.otp,
    this.operatorPrefix,
    this.parsedHeader,
    this.messageTypeSuffix,
    this.rawSender,
    this.normalizedSender,
    this.brandName,
    required this.classificationVersion,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['thread_id'] = Variable<String>(threadId);
    map['sender'] = Variable<String>(sender);
    map['header'] = Variable<String>(header);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['body'] = Variable<String>(body);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['category'] = Variable<String>(category);
    map['classification_confidence'] = Variable<double>(
      classificationConfidence,
    );
    map['classification_reason'] = Variable<String>(classificationReason);
    map['is_read'] = Variable<bool>(isRead);
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || otp != null) {
      map['otp'] = Variable<String>(otp);
    }
    if (!nullToAbsent || operatorPrefix != null) {
      map['operator_prefix'] = Variable<String>(operatorPrefix);
    }
    if (!nullToAbsent || parsedHeader != null) {
      map['parsed_header'] = Variable<String>(parsedHeader);
    }
    if (!nullToAbsent || messageTypeSuffix != null) {
      map['message_type_suffix'] = Variable<String>(messageTypeSuffix);
    }
    if (!nullToAbsent || rawSender != null) {
      map['raw_sender'] = Variable<String>(rawSender);
    }
    if (!nullToAbsent || normalizedSender != null) {
      map['normalized_sender'] = Variable<String>(normalizedSender);
    }
    if (!nullToAbsent || brandName != null) {
      map['brand_name'] = Variable<String>(brandName);
    }
    map['classification_version'] = Variable<int>(classificationVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      threadId: Value(threadId),
      sender: Value(sender),
      header: Value(header),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      body: Value(body),
      receivedAt: Value(receivedAt),
      category: Value(category),
      classificationConfidence: Value(classificationConfidence),
      classificationReason: Value(classificationReason),
      isRead: Value(isRead),
      isStarred: Value(isStarred),
      isPinned: Value(isPinned),
      isArchived: Value(isArchived),
      isDeleted: Value(isDeleted),
      otp: otp == null && nullToAbsent ? const Value.absent() : Value(otp),
      operatorPrefix: operatorPrefix == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorPrefix),
      parsedHeader: parsedHeader == null && nullToAbsent
          ? const Value.absent()
          : Value(parsedHeader),
      messageTypeSuffix: messageTypeSuffix == null && nullToAbsent
          ? const Value.absent()
          : Value(messageTypeSuffix),
      rawSender: rawSender == null && nullToAbsent
          ? const Value.absent()
          : Value(rawSender),
      normalizedSender: normalizedSender == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedSender),
      brandName: brandName == null && nullToAbsent
          ? const Value.absent()
          : Value(brandName),
      classificationVersion: Value(classificationVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      threadId: serializer.fromJson<String>(json['threadId']),
      sender: serializer.fromJson<String>(json['sender']),
      header: serializer.fromJson<String>(json['header']),
      brand: serializer.fromJson<String?>(json['brand']),
      body: serializer.fromJson<String>(json['body']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      category: serializer.fromJson<String>(json['category']),
      classificationConfidence: serializer.fromJson<double>(
        json['classificationConfidence'],
      ),
      classificationReason: serializer.fromJson<String>(
        json['classificationReason'],
      ),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      otp: serializer.fromJson<String?>(json['otp']),
      operatorPrefix: serializer.fromJson<String?>(json['operatorPrefix']),
      parsedHeader: serializer.fromJson<String?>(json['parsedHeader']),
      messageTypeSuffix: serializer.fromJson<String?>(
        json['messageTypeSuffix'],
      ),
      rawSender: serializer.fromJson<String?>(json['rawSender']),
      normalizedSender: serializer.fromJson<String?>(json['normalizedSender']),
      brandName: serializer.fromJson<String?>(json['brandName']),
      classificationVersion: serializer.fromJson<int>(
        json['classificationVersion'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threadId': serializer.toJson<String>(threadId),
      'sender': serializer.toJson<String>(sender),
      'header': serializer.toJson<String>(header),
      'brand': serializer.toJson<String?>(brand),
      'body': serializer.toJson<String>(body),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'category': serializer.toJson<String>(category),
      'classificationConfidence': serializer.toJson<double>(
        classificationConfidence,
      ),
      'classificationReason': serializer.toJson<String>(classificationReason),
      'isRead': serializer.toJson<bool>(isRead),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'otp': serializer.toJson<String?>(otp),
      'operatorPrefix': serializer.toJson<String?>(operatorPrefix),
      'parsedHeader': serializer.toJson<String?>(parsedHeader),
      'messageTypeSuffix': serializer.toJson<String?>(messageTypeSuffix),
      'rawSender': serializer.toJson<String?>(rawSender),
      'normalizedSender': serializer.toJson<String?>(normalizedSender),
      'brandName': serializer.toJson<String?>(brandName),
      'classificationVersion': serializer.toJson<int>(classificationVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Message copyWith({
    String? id,
    String? threadId,
    String? sender,
    String? header,
    Value<String?> brand = const Value.absent(),
    String? body,
    DateTime? receivedAt,
    String? category,
    double? classificationConfidence,
    String? classificationReason,
    bool? isRead,
    bool? isStarred,
    bool? isPinned,
    bool? isArchived,
    bool? isDeleted,
    Value<String?> otp = const Value.absent(),
    Value<String?> operatorPrefix = const Value.absent(),
    Value<String?> parsedHeader = const Value.absent(),
    Value<String?> messageTypeSuffix = const Value.absent(),
    Value<String?> rawSender = const Value.absent(),
    Value<String?> normalizedSender = const Value.absent(),
    Value<String?> brandName = const Value.absent(),
    int? classificationVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Message(
    id: id ?? this.id,
    threadId: threadId ?? this.threadId,
    sender: sender ?? this.sender,
    header: header ?? this.header,
    brand: brand.present ? brand.value : this.brand,
    body: body ?? this.body,
    receivedAt: receivedAt ?? this.receivedAt,
    category: category ?? this.category,
    classificationConfidence:
        classificationConfidence ?? this.classificationConfidence,
    classificationReason: classificationReason ?? this.classificationReason,
    isRead: isRead ?? this.isRead,
    isStarred: isStarred ?? this.isStarred,
    isPinned: isPinned ?? this.isPinned,
    isArchived: isArchived ?? this.isArchived,
    isDeleted: isDeleted ?? this.isDeleted,
    otp: otp.present ? otp.value : this.otp,
    operatorPrefix: operatorPrefix.present
        ? operatorPrefix.value
        : this.operatorPrefix,
    parsedHeader: parsedHeader.present ? parsedHeader.value : this.parsedHeader,
    messageTypeSuffix: messageTypeSuffix.present
        ? messageTypeSuffix.value
        : this.messageTypeSuffix,
    rawSender: rawSender.present ? rawSender.value : this.rawSender,
    normalizedSender: normalizedSender.present
        ? normalizedSender.value
        : this.normalizedSender,
    brandName: brandName.present ? brandName.value : this.brandName,
    classificationVersion: classificationVersion ?? this.classificationVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      sender: data.sender.present ? data.sender.value : this.sender,
      header: data.header.present ? data.header.value : this.header,
      brand: data.brand.present ? data.brand.value : this.brand,
      body: data.body.present ? data.body.value : this.body,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      category: data.category.present ? data.category.value : this.category,
      classificationConfidence: data.classificationConfidence.present
          ? data.classificationConfidence.value
          : this.classificationConfidence,
      classificationReason: data.classificationReason.present
          ? data.classificationReason.value
          : this.classificationReason,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      otp: data.otp.present ? data.otp.value : this.otp,
      operatorPrefix: data.operatorPrefix.present
          ? data.operatorPrefix.value
          : this.operatorPrefix,
      parsedHeader: data.parsedHeader.present
          ? data.parsedHeader.value
          : this.parsedHeader,
      messageTypeSuffix: data.messageTypeSuffix.present
          ? data.messageTypeSuffix.value
          : this.messageTypeSuffix,
      rawSender: data.rawSender.present ? data.rawSender.value : this.rawSender,
      normalizedSender: data.normalizedSender.present
          ? data.normalizedSender.value
          : this.normalizedSender,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      classificationVersion: data.classificationVersion.present
          ? data.classificationVersion.value
          : this.classificationVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('sender: $sender, ')
          ..write('header: $header, ')
          ..write('brand: $brand, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('category: $category, ')
          ..write('classificationConfidence: $classificationConfidence, ')
          ..write('classificationReason: $classificationReason, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('otp: $otp, ')
          ..write('operatorPrefix: $operatorPrefix, ')
          ..write('parsedHeader: $parsedHeader, ')
          ..write('messageTypeSuffix: $messageTypeSuffix, ')
          ..write('rawSender: $rawSender, ')
          ..write('normalizedSender: $normalizedSender, ')
          ..write('brandName: $brandName, ')
          ..write('classificationVersion: $classificationVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    threadId,
    sender,
    header,
    brand,
    body,
    receivedAt,
    category,
    classificationConfidence,
    classificationReason,
    isRead,
    isStarred,
    isPinned,
    isArchived,
    isDeleted,
    otp,
    operatorPrefix,
    parsedHeader,
    messageTypeSuffix,
    rawSender,
    normalizedSender,
    brandName,
    classificationVersion,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.sender == this.sender &&
          other.header == this.header &&
          other.brand == this.brand &&
          other.body == this.body &&
          other.receivedAt == this.receivedAt &&
          other.category == this.category &&
          other.classificationConfidence == this.classificationConfidence &&
          other.classificationReason == this.classificationReason &&
          other.isRead == this.isRead &&
          other.isStarred == this.isStarred &&
          other.isPinned == this.isPinned &&
          other.isArchived == this.isArchived &&
          other.isDeleted == this.isDeleted &&
          other.otp == this.otp &&
          other.operatorPrefix == this.operatorPrefix &&
          other.parsedHeader == this.parsedHeader &&
          other.messageTypeSuffix == this.messageTypeSuffix &&
          other.rawSender == this.rawSender &&
          other.normalizedSender == this.normalizedSender &&
          other.brandName == this.brandName &&
          other.classificationVersion == this.classificationVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> threadId;
  final Value<String> sender;
  final Value<String> header;
  final Value<String?> brand;
  final Value<String> body;
  final Value<DateTime> receivedAt;
  final Value<String> category;
  final Value<double> classificationConfidence;
  final Value<String> classificationReason;
  final Value<bool> isRead;
  final Value<bool> isStarred;
  final Value<bool> isPinned;
  final Value<bool> isArchived;
  final Value<bool> isDeleted;
  final Value<String?> otp;
  final Value<String?> operatorPrefix;
  final Value<String?> parsedHeader;
  final Value<String?> messageTypeSuffix;
  final Value<String?> rawSender;
  final Value<String?> normalizedSender;
  final Value<String?> brandName;
  final Value<int> classificationVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.sender = const Value.absent(),
    this.header = const Value.absent(),
    this.brand = const Value.absent(),
    this.body = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.classificationConfidence = const Value.absent(),
    this.classificationReason = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.otp = const Value.absent(),
    this.operatorPrefix = const Value.absent(),
    this.parsedHeader = const Value.absent(),
    this.messageTypeSuffix = const Value.absent(),
    this.rawSender = const Value.absent(),
    this.normalizedSender = const Value.absent(),
    this.brandName = const Value.absent(),
    this.classificationVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String threadId,
    required String sender,
    required String header,
    this.brand = const Value.absent(),
    required String body,
    required DateTime receivedAt,
    required String category,
    this.classificationConfidence = const Value.absent(),
    this.classificationReason = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.otp = const Value.absent(),
    this.operatorPrefix = const Value.absent(),
    this.parsedHeader = const Value.absent(),
    this.messageTypeSuffix = const Value.absent(),
    this.rawSender = const Value.absent(),
    this.normalizedSender = const Value.absent(),
    this.brandName = const Value.absent(),
    this.classificationVersion = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       threadId = Value(threadId),
       sender = Value(sender),
       header = Value(header),
       body = Value(body),
       receivedAt = Value(receivedAt),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? threadId,
    Expression<String>? sender,
    Expression<String>? header,
    Expression<String>? brand,
    Expression<String>? body,
    Expression<DateTime>? receivedAt,
    Expression<String>? category,
    Expression<double>? classificationConfidence,
    Expression<String>? classificationReason,
    Expression<bool>? isRead,
    Expression<bool>? isStarred,
    Expression<bool>? isPinned,
    Expression<bool>? isArchived,
    Expression<bool>? isDeleted,
    Expression<String>? otp,
    Expression<String>? operatorPrefix,
    Expression<String>? parsedHeader,
    Expression<String>? messageTypeSuffix,
    Expression<String>? rawSender,
    Expression<String>? normalizedSender,
    Expression<String>? brandName,
    Expression<int>? classificationVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (sender != null) 'sender': sender,
      if (header != null) 'header': header,
      if (brand != null) 'brand': brand,
      if (body != null) 'body': body,
      if (receivedAt != null) 'received_at': receivedAt,
      if (category != null) 'category': category,
      if (classificationConfidence != null)
        'classification_confidence': classificationConfidence,
      if (classificationReason != null)
        'classification_reason': classificationReason,
      if (isRead != null) 'is_read': isRead,
      if (isStarred != null) 'is_starred': isStarred,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isArchived != null) 'is_archived': isArchived,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (otp != null) 'otp': otp,
      if (operatorPrefix != null) 'operator_prefix': operatorPrefix,
      if (parsedHeader != null) 'parsed_header': parsedHeader,
      if (messageTypeSuffix != null) 'message_type_suffix': messageTypeSuffix,
      if (rawSender != null) 'raw_sender': rawSender,
      if (normalizedSender != null) 'normalized_sender': normalizedSender,
      if (brandName != null) 'brand_name': brandName,
      if (classificationVersion != null)
        'classification_version': classificationVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? threadId,
    Value<String>? sender,
    Value<String>? header,
    Value<String?>? brand,
    Value<String>? body,
    Value<DateTime>? receivedAt,
    Value<String>? category,
    Value<double>? classificationConfidence,
    Value<String>? classificationReason,
    Value<bool>? isRead,
    Value<bool>? isStarred,
    Value<bool>? isPinned,
    Value<bool>? isArchived,
    Value<bool>? isDeleted,
    Value<String?>? otp,
    Value<String?>? operatorPrefix,
    Value<String?>? parsedHeader,
    Value<String?>? messageTypeSuffix,
    Value<String?>? rawSender,
    Value<String?>? normalizedSender,
    Value<String?>? brandName,
    Value<int>? classificationVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      sender: sender ?? this.sender,
      header: header ?? this.header,
      brand: brand ?? this.brand,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      category: category ?? this.category,
      classificationConfidence:
          classificationConfidence ?? this.classificationConfidence,
      classificationReason: classificationReason ?? this.classificationReason,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      otp: otp ?? this.otp,
      operatorPrefix: operatorPrefix ?? this.operatorPrefix,
      parsedHeader: parsedHeader ?? this.parsedHeader,
      messageTypeSuffix: messageTypeSuffix ?? this.messageTypeSuffix,
      rawSender: rawSender ?? this.rawSender,
      normalizedSender: normalizedSender ?? this.normalizedSender,
      brandName: brandName ?? this.brandName,
      classificationVersion:
          classificationVersion ?? this.classificationVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (header.present) {
      map['header'] = Variable<String>(header.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (classificationConfidence.present) {
      map['classification_confidence'] = Variable<double>(
        classificationConfidence.value,
      );
    }
    if (classificationReason.present) {
      map['classification_reason'] = Variable<String>(
        classificationReason.value,
      );
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (otp.present) {
      map['otp'] = Variable<String>(otp.value);
    }
    if (operatorPrefix.present) {
      map['operator_prefix'] = Variable<String>(operatorPrefix.value);
    }
    if (parsedHeader.present) {
      map['parsed_header'] = Variable<String>(parsedHeader.value);
    }
    if (messageTypeSuffix.present) {
      map['message_type_suffix'] = Variable<String>(messageTypeSuffix.value);
    }
    if (rawSender.present) {
      map['raw_sender'] = Variable<String>(rawSender.value);
    }
    if (normalizedSender.present) {
      map['normalized_sender'] = Variable<String>(normalizedSender.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (classificationVersion.present) {
      map['classification_version'] = Variable<int>(
        classificationVersion.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('sender: $sender, ')
          ..write('header: $header, ')
          ..write('brand: $brand, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('category: $category, ')
          ..write('classificationConfidence: $classificationConfidence, ')
          ..write('classificationReason: $classificationReason, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('isPinned: $isPinned, ')
          ..write('isArchived: $isArchived, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('otp: $otp, ')
          ..write('operatorPrefix: $operatorPrefix, ')
          ..write('parsedHeader: $parsedHeader, ')
          ..write('messageTypeSuffix: $messageTypeSuffix, ')
          ..write('rawSender: $rawSender, ')
          ..write('normalizedSender: $normalizedSender, ')
          ..write('brandName: $brandName, ')
          ..write('classificationVersion: $classificationVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LabelsTable extends Labels with TableInfo<$LabelsTable, Label> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF6750A4),
  );
  static const VerificationMeta _iconCodeMeta = const VerificationMeta(
    'iconCode',
  );
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
    'icon_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xe362),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorValue,
    iconCode,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Label> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('icon_code')) {
      context.handle(
        _iconCodeMeta,
        iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Label map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Label(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      iconCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LabelsTable createAlias(String alias) {
    return $LabelsTable(attachedDatabase, alias);
  }
}

class Label extends DataClass implements Insertable<Label> {
  final String id;
  final String name;
  final int colorValue;
  final int iconCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Label({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['icon_code'] = Variable<int>(iconCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LabelsCompanion toCompanion(bool nullToAbsent) {
    return LabelsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      iconCode: Value(iconCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Label.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Label(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'iconCode': serializer.toJson<int>(iconCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Label copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Label(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    iconCode: iconCode ?? this.iconCode,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Label copyWithCompanion(LabelsCompanion data) {
    return Label(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Label(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCode: $iconCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorValue, iconCode, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.iconCode == this.iconCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LabelsCompanion extends UpdateCompanion<Label> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<int> iconCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LabelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LabelsCompanion.insert({
    required String id,
    required String name,
    this.colorValue = const Value.absent(),
    this.iconCode = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Label> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<int>? iconCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (iconCode != null) 'icon_code': iconCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LabelsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? colorValue,
    Value<int>? iconCode,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LabelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('iconCode: $iconCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageLabelsTable extends MessageLabels
    with TableInfo<$MessageLabelsTable, MessageLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<String> labelId = GeneratedColumn<String>(
    'label_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES labels (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [messageId, labelId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageLabel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId, labelId};
  @override
  MessageLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageLabel(
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_id'],
      )!,
    );
  }

  @override
  $MessageLabelsTable createAlias(String alias) {
    return $MessageLabelsTable(attachedDatabase, alias);
  }
}

class MessageLabel extends DataClass implements Insertable<MessageLabel> {
  final String messageId;
  final String labelId;
  const MessageLabel({required this.messageId, required this.labelId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['label_id'] = Variable<String>(labelId);
    return map;
  }

  MessageLabelsCompanion toCompanion(bool nullToAbsent) {
    return MessageLabelsCompanion(
      messageId: Value(messageId),
      labelId: Value(labelId),
    );
  }

  factory MessageLabel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageLabel(
      messageId: serializer.fromJson<String>(json['messageId']),
      labelId: serializer.fromJson<String>(json['labelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'labelId': serializer.toJson<String>(labelId),
    };
  }

  MessageLabel copyWith({String? messageId, String? labelId}) => MessageLabel(
    messageId: messageId ?? this.messageId,
    labelId: labelId ?? this.labelId,
  );
  MessageLabel copyWithCompanion(MessageLabelsCompanion data) {
    return MessageLabel(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageLabel(')
          ..write('messageId: $messageId, ')
          ..write('labelId: $labelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, labelId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageLabel &&
          other.messageId == this.messageId &&
          other.labelId == this.labelId);
}

class MessageLabelsCompanion extends UpdateCompanion<MessageLabel> {
  final Value<String> messageId;
  final Value<String> labelId;
  final Value<int> rowid;
  const MessageLabelsCompanion({
    this.messageId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageLabelsCompanion.insert({
    required String messageId,
    required String labelId,
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       labelId = Value(labelId);
  static Insertable<MessageLabel> custom({
    Expression<String>? messageId,
    Expression<String>? labelId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (labelId != null) 'label_id': labelId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageLabelsCompanion copyWith({
    Value<String>? messageId,
    Value<String>? labelId,
    Value<int>? rowid,
  }) {
    return MessageLabelsCompanion(
      messageId: messageId ?? this.messageId,
      labelId: labelId ?? this.labelId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<String>(labelId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageLabelsCompanion(')
          ..write('messageId: $messageId, ')
          ..write('labelId: $labelId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SenderMetadataTableTable extends SenderMetadataTable
    with TableInfo<$SenderMetadataTableTable, SenderMetadataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SenderMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headerMeta = const VerificationMeta('header');
  @override
  late final GeneratedColumn<String> header = GeneratedColumn<String>(
    'header',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationMeta = const VerificationMeta(
    'organization',
  );
  @override
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
    'organization',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _industryMeta = const VerificationMeta(
    'industry',
  );
  @override
  late final GeneratedColumn<String> industry = GeneratedColumn<String>(
    'industry',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataVersionMeta = const VerificationMeta(
    'metadataVersion',
  );
  @override
  late final GeneratedColumn<int> metadataVersion = GeneratedColumn<int>(
    'metadata_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    header,
    brand,
    organization,
    industry,
    metadataVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sender_metadata_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SenderMetadataTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('header')) {
      context.handle(
        _headerMeta,
        header.isAcceptableOrUnknown(data['header']!, _headerMeta),
      );
    } else if (isInserting) {
      context.missing(_headerMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('organization')) {
      context.handle(
        _organizationMeta,
        organization.isAcceptableOrUnknown(
          data['organization']!,
          _organizationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationMeta);
    }
    if (data.containsKey('industry')) {
      context.handle(
        _industryMeta,
        industry.isAcceptableOrUnknown(data['industry']!, _industryMeta),
      );
    } else if (isInserting) {
      context.missing(_industryMeta);
    }
    if (data.containsKey('metadata_version')) {
      context.handle(
        _metadataVersionMeta,
        metadataVersion.isAcceptableOrUnknown(
          data['metadata_version']!,
          _metadataVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SenderMetadataTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SenderMetadataTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      header: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}header'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      organization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization'],
      )!,
      industry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}industry'],
      )!,
      metadataVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metadata_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SenderMetadataTableTable createAlias(String alias) {
    return $SenderMetadataTableTable(attachedDatabase, alias);
  }
}

class SenderMetadataTableData extends DataClass
    implements Insertable<SenderMetadataTableData> {
  final String id;
  final String header;
  final String brand;
  final String organization;
  final String industry;
  final int metadataVersion;
  final DateTime updatedAt;
  const SenderMetadataTableData({
    required this.id,
    required this.header,
    required this.brand,
    required this.organization,
    required this.industry,
    required this.metadataVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['header'] = Variable<String>(header);
    map['brand'] = Variable<String>(brand);
    map['organization'] = Variable<String>(organization);
    map['industry'] = Variable<String>(industry);
    map['metadata_version'] = Variable<int>(metadataVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SenderMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return SenderMetadataTableCompanion(
      id: Value(id),
      header: Value(header),
      brand: Value(brand),
      organization: Value(organization),
      industry: Value(industry),
      metadataVersion: Value(metadataVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory SenderMetadataTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SenderMetadataTableData(
      id: serializer.fromJson<String>(json['id']),
      header: serializer.fromJson<String>(json['header']),
      brand: serializer.fromJson<String>(json['brand']),
      organization: serializer.fromJson<String>(json['organization']),
      industry: serializer.fromJson<String>(json['industry']),
      metadataVersion: serializer.fromJson<int>(json['metadataVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'header': serializer.toJson<String>(header),
      'brand': serializer.toJson<String>(brand),
      'organization': serializer.toJson<String>(organization),
      'industry': serializer.toJson<String>(industry),
      'metadataVersion': serializer.toJson<int>(metadataVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SenderMetadataTableData copyWith({
    String? id,
    String? header,
    String? brand,
    String? organization,
    String? industry,
    int? metadataVersion,
    DateTime? updatedAt,
  }) => SenderMetadataTableData(
    id: id ?? this.id,
    header: header ?? this.header,
    brand: brand ?? this.brand,
    organization: organization ?? this.organization,
    industry: industry ?? this.industry,
    metadataVersion: metadataVersion ?? this.metadataVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SenderMetadataTableData copyWithCompanion(SenderMetadataTableCompanion data) {
    return SenderMetadataTableData(
      id: data.id.present ? data.id.value : this.id,
      header: data.header.present ? data.header.value : this.header,
      brand: data.brand.present ? data.brand.value : this.brand,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      industry: data.industry.present ? data.industry.value : this.industry,
      metadataVersion: data.metadataVersion.present
          ? data.metadataVersion.value
          : this.metadataVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SenderMetadataTableData(')
          ..write('id: $id, ')
          ..write('header: $header, ')
          ..write('brand: $brand, ')
          ..write('organization: $organization, ')
          ..write('industry: $industry, ')
          ..write('metadataVersion: $metadataVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    header,
    brand,
    organization,
    industry,
    metadataVersion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SenderMetadataTableData &&
          other.id == this.id &&
          other.header == this.header &&
          other.brand == this.brand &&
          other.organization == this.organization &&
          other.industry == this.industry &&
          other.metadataVersion == this.metadataVersion &&
          other.updatedAt == this.updatedAt);
}

class SenderMetadataTableCompanion
    extends UpdateCompanion<SenderMetadataTableData> {
  final Value<String> id;
  final Value<String> header;
  final Value<String> brand;
  final Value<String> organization;
  final Value<String> industry;
  final Value<int> metadataVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SenderMetadataTableCompanion({
    this.id = const Value.absent(),
    this.header = const Value.absent(),
    this.brand = const Value.absent(),
    this.organization = const Value.absent(),
    this.industry = const Value.absent(),
    this.metadataVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SenderMetadataTableCompanion.insert({
    required String id,
    required String header,
    required String brand,
    required String organization,
    required String industry,
    this.metadataVersion = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       header = Value(header),
       brand = Value(brand),
       organization = Value(organization),
       industry = Value(industry),
       updatedAt = Value(updatedAt);
  static Insertable<SenderMetadataTableData> custom({
    Expression<String>? id,
    Expression<String>? header,
    Expression<String>? brand,
    Expression<String>? organization,
    Expression<String>? industry,
    Expression<int>? metadataVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (header != null) 'header': header,
      if (brand != null) 'brand': brand,
      if (organization != null) 'organization': organization,
      if (industry != null) 'industry': industry,
      if (metadataVersion != null) 'metadata_version': metadataVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SenderMetadataTableCompanion copyWith({
    Value<String>? id,
    Value<String>? header,
    Value<String>? brand,
    Value<String>? organization,
    Value<String>? industry,
    Value<int>? metadataVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SenderMetadataTableCompanion(
      id: id ?? this.id,
      header: header ?? this.header,
      brand: brand ?? this.brand,
      organization: organization ?? this.organization,
      industry: industry ?? this.industry,
      metadataVersion: metadataVersion ?? this.metadataVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (header.present) {
      map['header'] = Variable<String>(header.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (industry.present) {
      map['industry'] = Variable<String>(industry.value);
    }
    if (metadataVersion.present) {
      map['metadata_version'] = Variable<int>(metadataVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SenderMetadataTableCompanion(')
          ..write('id: $id, ')
          ..write('header: $header, ')
          ..write('brand: $brand, ')
          ..write('organization: $organization, ')
          ..write('industry: $industry, ')
          ..write('metadataVersion: $metadataVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $LabelsTable labels = $LabelsTable(this);
  late final $MessageLabelsTable messageLabels = $MessageLabelsTable(this);
  late final $SenderMetadataTableTable senderMetadataTable =
      $SenderMetadataTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    messages,
    labels,
    messageLabels,
    senderMetadataTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_labels', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'labels',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_labels', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String threadId,
      required String sender,
      required String header,
      Value<String?> brand,
      required String body,
      required DateTime receivedAt,
      required String category,
      Value<double> classificationConfidence,
      Value<String> classificationReason,
      Value<bool> isRead,
      Value<bool> isStarred,
      Value<bool> isPinned,
      Value<bool> isArchived,
      Value<bool> isDeleted,
      Value<String?> otp,
      Value<String?> operatorPrefix,
      Value<String?> parsedHeader,
      Value<String?> messageTypeSuffix,
      Value<String?> rawSender,
      Value<String?> normalizedSender,
      Value<String?> brandName,
      Value<int> classificationVersion,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> threadId,
      Value<String> sender,
      Value<String> header,
      Value<String?> brand,
      Value<String> body,
      Value<DateTime> receivedAt,
      Value<String> category,
      Value<double> classificationConfidence,
      Value<String> classificationReason,
      Value<bool> isRead,
      Value<bool> isStarred,
      Value<bool> isPinned,
      Value<bool> isArchived,
      Value<bool> isDeleted,
      Value<String?> otp,
      Value<String?> operatorPrefix,
      Value<String?> parsedHeader,
      Value<String?> messageTypeSuffix,
      Value<String?> rawSender,
      Value<String?> normalizedSender,
      Value<String?> brandName,
      Value<int> classificationVersion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessageLabelsTable, List<MessageLabel>>
  _messageLabelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.messageLabels,
    aliasName: 'messages__id__message_labels__message_id',
  );

  $$MessageLabelsTableProcessedTableManager get messageLabelsRefs {
    final manager = $$MessageLabelsTableTableManager(
      $_db,
      $_db.messageLabels,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messageLabelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get classificationConfidence => $composableBuilder(
    column: $table.classificationConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classificationReason => $composableBuilder(
    column: $table.classificationReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otp => $composableBuilder(
    column: $table.otp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorPrefix => $composableBuilder(
    column: $table.operatorPrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parsedHeader => $composableBuilder(
    column: $table.parsedHeader,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageTypeSuffix => $composableBuilder(
    column: $table.messageTypeSuffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSender => $composableBuilder(
    column: $table.rawSender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedSender => $composableBuilder(
    column: $table.normalizedSender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get classificationVersion => $composableBuilder(
    column: $table.classificationVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messageLabelsRefs(
    Expression<bool> Function($$MessageLabelsTableFilterComposer f) f,
  ) {
    final $$MessageLabelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageLabels,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageLabelsTableFilterComposer(
            $db: $db,
            $table: $db.messageLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get threadId => $composableBuilder(
    column: $table.threadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get classificationConfidence => $composableBuilder(
    column: $table.classificationConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classificationReason => $composableBuilder(
    column: $table.classificationReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otp => $composableBuilder(
    column: $table.otp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorPrefix => $composableBuilder(
    column: $table.operatorPrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parsedHeader => $composableBuilder(
    column: $table.parsedHeader,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageTypeSuffix => $composableBuilder(
    column: $table.messageTypeSuffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSender => $composableBuilder(
    column: $table.rawSender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedSender => $composableBuilder(
    column: $table.normalizedSender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get classificationVersion => $composableBuilder(
    column: $table.classificationVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get header =>
      $composableBuilder(column: $table.header, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get classificationConfidence => $composableBuilder(
    column: $table.classificationConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get classificationReason => $composableBuilder(
    column: $table.classificationReason,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get otp =>
      $composableBuilder(column: $table.otp, builder: (column) => column);

  GeneratedColumn<String> get operatorPrefix => $composableBuilder(
    column: $table.operatorPrefix,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parsedHeader => $composableBuilder(
    column: $table.parsedHeader,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageTypeSuffix => $composableBuilder(
    column: $table.messageTypeSuffix,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawSender =>
      $composableBuilder(column: $table.rawSender, builder: (column) => column);

  GeneratedColumn<String> get normalizedSender => $composableBuilder(
    column: $table.normalizedSender,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<int> get classificationVersion => $composableBuilder(
    column: $table.classificationVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> messageLabelsRefs<T extends Object>(
    Expression<T> Function($$MessageLabelsTableAnnotationComposer a) f,
  ) {
    final $$MessageLabelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageLabels,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageLabelsTableAnnotationComposer(
            $db: $db,
            $table: $db.messageLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool messageLabelsRefs})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> threadId = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> header = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> classificationConfidence = const Value.absent(),
                Value<String> classificationReason = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> otp = const Value.absent(),
                Value<String?> operatorPrefix = const Value.absent(),
                Value<String?> parsedHeader = const Value.absent(),
                Value<String?> messageTypeSuffix = const Value.absent(),
                Value<String?> rawSender = const Value.absent(),
                Value<String?> normalizedSender = const Value.absent(),
                Value<String?> brandName = const Value.absent(),
                Value<int> classificationVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                threadId: threadId,
                sender: sender,
                header: header,
                brand: brand,
                body: body,
                receivedAt: receivedAt,
                category: category,
                classificationConfidence: classificationConfidence,
                classificationReason: classificationReason,
                isRead: isRead,
                isStarred: isStarred,
                isPinned: isPinned,
                isArchived: isArchived,
                isDeleted: isDeleted,
                otp: otp,
                operatorPrefix: operatorPrefix,
                parsedHeader: parsedHeader,
                messageTypeSuffix: messageTypeSuffix,
                rawSender: rawSender,
                normalizedSender: normalizedSender,
                brandName: brandName,
                classificationVersion: classificationVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String threadId,
                required String sender,
                required String header,
                Value<String?> brand = const Value.absent(),
                required String body,
                required DateTime receivedAt,
                required String category,
                Value<double> classificationConfidence = const Value.absent(),
                Value<String> classificationReason = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> otp = const Value.absent(),
                Value<String?> operatorPrefix = const Value.absent(),
                Value<String?> parsedHeader = const Value.absent(),
                Value<String?> messageTypeSuffix = const Value.absent(),
                Value<String?> rawSender = const Value.absent(),
                Value<String?> normalizedSender = const Value.absent(),
                Value<String?> brandName = const Value.absent(),
                Value<int> classificationVersion = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                threadId: threadId,
                sender: sender,
                header: header,
                brand: brand,
                body: body,
                receivedAt: receivedAt,
                category: category,
                classificationConfidence: classificationConfidence,
                classificationReason: classificationReason,
                isRead: isRead,
                isStarred: isStarred,
                isPinned: isPinned,
                isArchived: isArchived,
                isDeleted: isDeleted,
                otp: otp,
                operatorPrefix: operatorPrefix,
                parsedHeader: parsedHeader,
                messageTypeSuffix: messageTypeSuffix,
                rawSender: rawSender,
                normalizedSender: normalizedSender,
                brandName: brandName,
                classificationVersion: classificationVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageLabelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (messageLabelsRefs) db.messageLabels,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messageLabelsRefs)
                    await $_getPrefetchedData<
                      Message,
                      $MessagesTable,
                      MessageLabel
                    >(
                      currentTable: table,
                      referencedTable: $$MessagesTableReferences
                          ._messageLabelsRefsTable(db),
                      managerFromTypedResult: (p0) => $$MessagesTableReferences(
                        db,
                        table,
                        p0,
                      ).messageLabelsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.messageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool messageLabelsRefs})
    >;
typedef $$LabelsTableCreateCompanionBuilder =
    LabelsCompanion Function({
      required String id,
      required String name,
      Value<int> colorValue,
      Value<int> iconCode,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LabelsTableUpdateCompanionBuilder =
    LabelsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> colorValue,
      Value<int> iconCode,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$LabelsTableReferences
    extends BaseReferences<_$AppDatabase, $LabelsTable, Label> {
  $$LabelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessageLabelsTable, List<MessageLabel>>
  _messageLabelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.messageLabels,
    aliasName: 'labels__id__message_labels__label_id',
  );

  $$MessageLabelsTableProcessedTableManager get messageLabelsRefs {
    final manager = $$MessageLabelsTableTableManager(
      $_db,
      $_db.messageLabels,
    ).filter((f) => f.labelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messageLabelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LabelsTableFilterComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messageLabelsRefs(
    Expression<bool> Function($$MessageLabelsTableFilterComposer f) f,
  ) {
    final $$MessageLabelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageLabels,
      getReferencedColumn: (t) => t.labelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageLabelsTableFilterComposer(
            $db: $db,
            $table: $db.messageLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCode => $composableBuilder(
    column: $table.iconCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabelsTable> {
  $$LabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> messageLabelsRefs<T extends Object>(
    Expression<T> Function($$MessageLabelsTableAnnotationComposer a) f,
  ) {
    final $$MessageLabelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageLabels,
      getReferencedColumn: (t) => t.labelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageLabelsTableAnnotationComposer(
            $db: $db,
            $table: $db.messageLabels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabelsTable,
          Label,
          $$LabelsTableFilterComposer,
          $$LabelsTableOrderingComposer,
          $$LabelsTableAnnotationComposer,
          $$LabelsTableCreateCompanionBuilder,
          $$LabelsTableUpdateCompanionBuilder,
          (Label, $$LabelsTableReferences),
          Label,
          PrefetchHooks Function({bool messageLabelsRefs})
        > {
  $$LabelsTableTableManager(_$AppDatabase db, $LabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabelsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                iconCode: iconCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> colorValue = const Value.absent(),
                Value<int> iconCode = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LabelsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                iconCode: iconCode,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LabelsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({messageLabelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (messageLabelsRefs) db.messageLabels,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messageLabelsRefs)
                    await $_getPrefetchedData<
                      Label,
                      $LabelsTable,
                      MessageLabel
                    >(
                      currentTable: table,
                      referencedTable: $$LabelsTableReferences
                          ._messageLabelsRefsTable(db),
                      managerFromTypedResult: (p0) => $$LabelsTableReferences(
                        db,
                        table,
                        p0,
                      ).messageLabelsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.labelId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabelsTable,
      Label,
      $$LabelsTableFilterComposer,
      $$LabelsTableOrderingComposer,
      $$LabelsTableAnnotationComposer,
      $$LabelsTableCreateCompanionBuilder,
      $$LabelsTableUpdateCompanionBuilder,
      (Label, $$LabelsTableReferences),
      Label,
      PrefetchHooks Function({bool messageLabelsRefs})
    >;
typedef $$MessageLabelsTableCreateCompanionBuilder =
    MessageLabelsCompanion Function({
      required String messageId,
      required String labelId,
      Value<int> rowid,
    });
typedef $$MessageLabelsTableUpdateCompanionBuilder =
    MessageLabelsCompanion Function({
      Value<String> messageId,
      Value<String> labelId,
      Value<int> rowid,
    });

final class $$MessageLabelsTableReferences
    extends BaseReferences<_$AppDatabase, $MessageLabelsTable, MessageLabel> {
  $$MessageLabelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MessagesTable _messageIdTable(_$AppDatabase db) =>
      db.messages.createAlias('message_labels__message_id__messages__id');

  $$MessagesTableProcessedTableManager get messageId {
    final $_column = $_itemColumn<String>('message_id')!;

    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LabelsTable _labelIdTable(_$AppDatabase db) =>
      db.labels.createAlias('message_labels__label_id__labels__id');

  $$LabelsTableProcessedTableManager get labelId {
    final $_column = $_itemColumn<String>('label_id')!;

    final manager = $$LabelsTableTableManager(
      $_db,
      $_db.labels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_labelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessageLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $MessageLabelsTable> {
  $$MessageLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MessagesTableFilterComposer get messageId {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LabelsTableFilterComposer get labelId {
    final $$LabelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.labelId,
      referencedTable: $db.labels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LabelsTableFilterComposer(
            $db: $db,
            $table: $db.labels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageLabelsTable> {
  $$MessageLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MessagesTableOrderingComposer get messageId {
    final $$MessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableOrderingComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LabelsTableOrderingComposer get labelId {
    final $$LabelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.labelId,
      referencedTable: $db.labels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LabelsTableOrderingComposer(
            $db: $db,
            $table: $db.labels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageLabelsTable> {
  $$MessageLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MessagesTableAnnotationComposer get messageId {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LabelsTableAnnotationComposer get labelId {
    final $$LabelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.labelId,
      referencedTable: $db.labels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LabelsTableAnnotationComposer(
            $db: $db,
            $table: $db.labels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageLabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageLabelsTable,
          MessageLabel,
          $$MessageLabelsTableFilterComposer,
          $$MessageLabelsTableOrderingComposer,
          $$MessageLabelsTableAnnotationComposer,
          $$MessageLabelsTableCreateCompanionBuilder,
          $$MessageLabelsTableUpdateCompanionBuilder,
          (MessageLabel, $$MessageLabelsTableReferences),
          MessageLabel,
          PrefetchHooks Function({bool messageId, bool labelId})
        > {
  $$MessageLabelsTableTableManager(_$AppDatabase db, $MessageLabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String> labelId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageLabelsCompanion(
                messageId: messageId,
                labelId: labelId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                required String labelId,
                Value<int> rowid = const Value.absent(),
              }) => MessageLabelsCompanion.insert(
                messageId: messageId,
                labelId: labelId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessageLabelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageId = false, labelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable: $$MessageLabelsTableReferences
                                    ._messageIdTable(db),
                                referencedColumn: $$MessageLabelsTableReferences
                                    ._messageIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (labelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.labelId,
                                referencedTable: $$MessageLabelsTableReferences
                                    ._labelIdTable(db),
                                referencedColumn: $$MessageLabelsTableReferences
                                    ._labelIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessageLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageLabelsTable,
      MessageLabel,
      $$MessageLabelsTableFilterComposer,
      $$MessageLabelsTableOrderingComposer,
      $$MessageLabelsTableAnnotationComposer,
      $$MessageLabelsTableCreateCompanionBuilder,
      $$MessageLabelsTableUpdateCompanionBuilder,
      (MessageLabel, $$MessageLabelsTableReferences),
      MessageLabel,
      PrefetchHooks Function({bool messageId, bool labelId})
    >;
typedef $$SenderMetadataTableTableCreateCompanionBuilder =
    SenderMetadataTableCompanion Function({
      required String id,
      required String header,
      required String brand,
      required String organization,
      required String industry,
      Value<int> metadataVersion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SenderMetadataTableTableUpdateCompanionBuilder =
    SenderMetadataTableCompanion Function({
      Value<String> id,
      Value<String> header,
      Value<String> brand,
      Value<String> organization,
      Value<String> industry,
      Value<int> metadataVersion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SenderMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $SenderMetadataTableTable> {
  $$SenderMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get industry => $composableBuilder(
    column: $table.industry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metadataVersion => $composableBuilder(
    column: $table.metadataVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SenderMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SenderMetadataTableTable> {
  $$SenderMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get header => $composableBuilder(
    column: $table.header,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get industry => $composableBuilder(
    column: $table.industry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metadataVersion => $composableBuilder(
    column: $table.metadataVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SenderMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SenderMetadataTableTable> {
  $$SenderMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get header =>
      $composableBuilder(column: $table.header, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get organization => $composableBuilder(
    column: $table.organization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get industry =>
      $composableBuilder(column: $table.industry, builder: (column) => column);

  GeneratedColumn<int> get metadataVersion => $composableBuilder(
    column: $table.metadataVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SenderMetadataTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SenderMetadataTableTable,
          SenderMetadataTableData,
          $$SenderMetadataTableTableFilterComposer,
          $$SenderMetadataTableTableOrderingComposer,
          $$SenderMetadataTableTableAnnotationComposer,
          $$SenderMetadataTableTableCreateCompanionBuilder,
          $$SenderMetadataTableTableUpdateCompanionBuilder,
          (
            SenderMetadataTableData,
            BaseReferences<
              _$AppDatabase,
              $SenderMetadataTableTable,
              SenderMetadataTableData
            >,
          ),
          SenderMetadataTableData,
          PrefetchHooks Function()
        > {
  $$SenderMetadataTableTableTableManager(
    _$AppDatabase db,
    $SenderMetadataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SenderMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SenderMetadataTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SenderMetadataTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> header = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> organization = const Value.absent(),
                Value<String> industry = const Value.absent(),
                Value<int> metadataVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SenderMetadataTableCompanion(
                id: id,
                header: header,
                brand: brand,
                organization: organization,
                industry: industry,
                metadataVersion: metadataVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String header,
                required String brand,
                required String organization,
                required String industry,
                Value<int> metadataVersion = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SenderMetadataTableCompanion.insert(
                id: id,
                header: header,
                brand: brand,
                organization: organization,
                industry: industry,
                metadataVersion: metadataVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SenderMetadataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SenderMetadataTableTable,
      SenderMetadataTableData,
      $$SenderMetadataTableTableFilterComposer,
      $$SenderMetadataTableTableOrderingComposer,
      $$SenderMetadataTableTableAnnotationComposer,
      $$SenderMetadataTableTableCreateCompanionBuilder,
      $$SenderMetadataTableTableUpdateCompanionBuilder,
      (
        SenderMetadataTableData,
        BaseReferences<
          _$AppDatabase,
          $SenderMetadataTableTable,
          SenderMetadataTableData
        >,
      ),
      SenderMetadataTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$LabelsTableTableManager get labels =>
      $$LabelsTableTableManager(_db, _db.labels);
  $$MessageLabelsTableTableManager get messageLabels =>
      $$MessageLabelsTableTableManager(_db, _db.messageLabels);
  $$SenderMetadataTableTableTableManager get senderMetadataTable =>
      $$SenderMetadataTableTableTableManager(_db, _db.senderMetadataTable);
}
