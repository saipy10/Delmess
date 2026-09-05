import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/sms_header_parser.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';

/// Normalizer responsible for converting RawSmsMessage DTOs to the application domain SmsMessage.
class SmsNormalizer {
  static const SmsHeaderParser _headerParser = SmsHeaderParser();

  /// Normalizes a single [RawSmsMessage] into a domain [SmsMessage].
  static SmsMessage normalize(RawSmsMessage raw) {
    // Preserve raw sender exactly as provided by Android
    final sender = raw.sender.trim().isEmpty ? 'Unknown' : raw.sender.trim();
    final body = raw.body;

    final receivedAt = DateTime.fromMillisecondsSinceEpoch(
      raw.receivedAtMillis,
      isUtc: false,
    );

    final now = DateTime.now();
    final parsed = _headerParser.parse(sender);

    return SmsMessage(
      id: raw.id.trim().isEmpty ? 'sms_${raw.receivedAtMillis}' : raw.id.trim(),
      threadId: raw.threadId.trim().isEmpty
          ? (raw.id.trim().isEmpty
                ? 'thread_${raw.receivedAtMillis}'
                : raw.id.trim())
          : raw.threadId.trim(),
      sender: sender,
      rawSender: sender,
      normalizedSender: parsed.normalizedSender,
      header: sender,
      brand: null,
      body: body,
      receivedAt: receivedAt,
      category: CategoryType.other,
      classificationConfidence: 1.0,
      classificationReason: ClassificationReason.unknown,
      isRead: raw.isRead,
      isStarred: false,
      isPinned: false,
      isArchived: false,
      isDeleted: false,
      otp: null,
      operatorPrefix: parsed.operatorPrefix,
      parsedHeader: parsed.cleanHeader,
      messageTypeSuffix: parsed.suffix,
      classificationVersion: 1,
      labels: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Normalizes a batch of [RawSmsMessage] DTOs.
  static List<SmsMessage> normalizeBatch(List<RawSmsMessage> rawBatch) {
    return rawBatch.map(normalize).toList();
  }
}

