import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';

/// Conversation grouping multiple SMS messages from the same sender or thread.
class SmsConversation {
  final String id;
  final String sender;
  final String senderDisplayName;
  final CategoryType category;
  final List<SmsMessage> messages;
  final bool isStarred;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final List<LabelModel> labels;

  const SmsConversation({
    required this.id,
    required this.sender,
    required this.senderDisplayName,
    required this.category,
    required this.messages,
    this.isStarred = false,
    this.isPinned = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.labels = const [],
  });

  SmsMessage get latestMessage => messages.first;
  DateTime get latestTimestamp => latestMessage.receivedAt;
  bool get hasUnread => messages.any((m) => !m.isRead);
  String? get latestOtp => latestMessage.otp;

  SmsConversation copyWith({
    String? id,
    String? sender,
    String? senderDisplayName,
    CategoryType? category,
    List<SmsMessage>? messages,
    bool? isStarred,
    bool? isPinned,
    bool? isArchived,
    bool? isDeleted,
    List<LabelModel>? labels,
  }) {
    return SmsConversation(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      category: category ?? this.category,
      messages: messages ?? this.messages,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      labels: labels ?? this.labels,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsConversation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sender == other.sender &&
          senderDisplayName == other.senderDisplayName &&
          category == other.category &&
          isStarred == other.isStarred &&
          isPinned == other.isPinned &&
          isArchived == other.isArchived &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      sender.hashCode ^
      senderDisplayName.hashCode ^
      category.hashCode ^
      isStarred.hashCode ^
      isPinned.hashCode ^
      isArchived.hashCode ^
      isDeleted.hashCode;
}
