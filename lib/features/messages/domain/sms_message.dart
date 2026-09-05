import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Single SMS Message entity representing normalized database and domain state.
class SmsMessage {
  final String id;
  final String threadId;
  final String sender;
  final String? rawSender;
  final String? normalizedSender;
  final String header;
  final String? brand;
  final String? brandNameField;
  final String body;
  final DateTime receivedAt;
  final CategoryType category;
  final double classificationConfidence;
  final ClassificationReason classificationReason;
  final String? reasonDescription;
  final bool isRead;
  final bool isStarred;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final String? otp;
  final String? operatorPrefix;
  final String? parsedHeader;
  final String? messageTypeSuffix;
  final int classificationVersion;
  final List<LabelModel> labels;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SmsMessage({
    required this.id,
    required this.threadId,
    required this.sender,
    this.rawSender,
    this.normalizedSender,
    required this.header,
    this.brand,
    this.brandNameField,
    required this.body,
    required this.receivedAt,
    required this.category,
    this.classificationConfidence = 1.0,
    this.classificationReason = ClassificationReason.unknown,
    this.reasonDescription,
    this.isRead = false,
    this.isStarred = false,
    this.isPinned = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.otp,
    this.operatorPrefix,
    this.parsedHeader,
    this.messageTypeSuffix,
    this.classificationVersion = 1,
    this.labels = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Resolved brand name with fallback to brand or empty string.
  String get brandName => brandNameField ?? brand ?? '';

  /// Effective raw sender string.
  String get effectiveRawSender => rawSender ?? sender;

  /// Effective classification reason description string.
  String get effectiveReasonDescription =>
      reasonDescription ?? classificationReason.displayName;

  /// Backwards-compatible alias for receivedAt.
  DateTime get timestamp => receivedAt;

  SmsMessage copyWith({
    String? id,
    String? threadId,
    String? sender,
    String? rawSender,
    String? normalizedSender,
    String? header,
    String? brand,
    String? brandNameField,
    String? body,
    DateTime? receivedAt,
    CategoryType? category,
    double? classificationConfidence,
    ClassificationReason? classificationReason,
    String? reasonDescription,
    bool? isRead,
    bool? isStarred,
    bool? isPinned,
    bool? isArchived,
    bool? isDeleted,
    String? otp,
    String? operatorPrefix,
    String? parsedHeader,
    String? messageTypeSuffix,
    int? classificationVersion,
    List<LabelModel>? labels,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      sender: sender ?? this.sender,
      rawSender: rawSender ?? this.rawSender,
      normalizedSender: normalizedSender ?? this.normalizedSender,
      header: header ?? this.header,
      brand: brand ?? this.brand,
      brandNameField: brandNameField ?? this.brandNameField,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      category: category ?? this.category,
      classificationConfidence:
          classificationConfidence ?? this.classificationConfidence,
      classificationReason: classificationReason ?? this.classificationReason,
      reasonDescription: reasonDescription ?? this.reasonDescription,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      otp: otp ?? this.otp,
      operatorPrefix: operatorPrefix ?? this.operatorPrefix,
      parsedHeader: parsedHeader ?? this.parsedHeader,
      messageTypeSuffix: messageTypeSuffix ?? this.messageTypeSuffix,
      classificationVersion:
          classificationVersion ?? this.classificationVersion,
      labels: labels ?? this.labels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          threadId == other.threadId &&
          sender == other.sender &&
          header == other.header &&
          brand == other.brand &&
          body == other.body &&
          receivedAt == other.receivedAt &&
          category == other.category &&
          classificationConfidence == other.classificationConfidence &&
          classificationReason == other.classificationReason &&
          isRead == other.isRead &&
          isStarred == other.isStarred &&
          isPinned == other.isPinned &&
          isArchived == other.isArchived &&
          isDeleted == other.isDeleted &&
          otp == other.otp &&
          operatorPrefix == other.operatorPrefix &&
          parsedHeader == other.parsedHeader &&
          messageTypeSuffix == other.messageTypeSuffix &&
          classificationVersion == other.classificationVersion &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      threadId.hashCode ^
      sender.hashCode ^
      header.hashCode ^
      brand.hashCode ^
      body.hashCode ^
      receivedAt.hashCode ^
      category.hashCode ^
      classificationConfidence.hashCode ^
      classificationReason.hashCode ^
      isRead.hashCode ^
      isStarred.hashCode ^
      isPinned.hashCode ^
      isArchived.hashCode ^
      isDeleted.hashCode ^
      otp.hashCode ^
      operatorPrefix.hashCode ^
      parsedHeader.hashCode ^
      messageTypeSuffix.hashCode ^
      classificationVersion.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
