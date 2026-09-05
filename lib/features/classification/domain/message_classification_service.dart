import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/features/classification/domain/classification_engine.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Orchestrates message classification, batch processing, and repeatable reclassification.
class MessageClassificationService {
  /// Current classifier algorithm version for schema tracking.
  static const int currentClassifierVersion = 2;

  final ClassificationEngine engine;
  final MessageRepository repository;

  MessageClassificationService({
    required this.engine,
    required this.repository,
  });

  /// Classifies a single [SmsMessage] and applies classification results to the entity.
  Future<SmsMessage> classifyMessage(SmsMessage message) async {
    try {
      final result = await engine.classify(
        sender: message.effectiveRawSender,
        body: message.body,
      );

      return message.copyWith(
        header: result.parsedHeader.cleanHeader,
        rawSender: message.rawSender ?? result.parsedHeader.rawSender,
        normalizedSender: result.parsedHeader.normalizedSender,
        category: result.category,
        classificationConfidence: result.confidence,
        classificationReason: result.reason,
        reasonDescription: result.effectiveReason,
        brand: result.brand,
        brandNameField: result.brand,
        otp: result.detectedOtp,
        operatorPrefix: result.parsedHeader.operatorPrefix,
        parsedHeader: result.parsedHeader.cleanHeader,
        messageTypeSuffix: result.parsedHeader.suffix,
        classificationVersion: currentClassifierVersion,
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      // Safe fallback on classification error
      return message.copyWith(
        category: CategoryType.other,
        classificationConfidence: 0.0,
        classificationReason: ClassificationReason.unknown,
        reasonDescription: 'Classification error fallback',
        classificationVersion: currentClassifierVersion,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Automatically checks and reclassifies existing messages whose category
  /// can be improved under the current classification rules (e.g. AX-HDFCBN-P under Other).
  Future<int> reclassifyIfNeeded() async {
    try {
      final messages = await repository.getAllMessages();
      final needsUpdate = messages.where((m) {
        // Needs update if version is older
        if (m.classificationVersion < currentClassifierVersion) return true;
        // Or if in 'other' but sender has commercial indicators
        if (m.category == CategoryType.other) {
          final s = m.sender.toUpperCase();
          if (s.contains('-P') ||
              s.contains('-S') ||
              s.contains('-T') ||
              s.contains('-G') ||
              s.contains('_P') ||
              s.contains('_S') ||
              s.contains('_T') ||
              s.contains('_G')) {
            return true;
          }
        }
        return false;
      }).toList();

      if (needsUpdate.isEmpty) return 0;

      final updated = await classifyBatch(needsUpdate);
      await repository.insertMessages(updated);
      return updated.length;
    } catch (_) {
      return 0;
    }
  }

  /// Classifies a batch of [SmsMessage]s safely without failing the whole batch.
  Future<List<SmsMessage>> classifyBatch(List<SmsMessage> messages) async {
    final results = <SmsMessage>[];
    for (final msg in messages) {
      final classified = await classifyMessage(msg);
      results.add(classified);
    }
    return results;
  }

  /// Reclassifies an existing persisted message by [messageId] and saves the update.
  Future<SmsMessage?> reclassifyMessage(String messageId) async {
    final existing = await repository.getMessageById(messageId);
    if (existing == null) return null;

    final updated = await classifyMessage(existing);
    await repository.insertMessage(updated);
    return updated;
  }

  /// Reclassifies a specific list of messages by [messageIds].
  Future<List<SmsMessage>> reclassifyMessages(List<String> messageIds) async {
    final updatedList = <SmsMessage>[];
    for (final id in messageIds) {
      final updated = await reclassifyMessage(id);
      if (updated != null) {
        updatedList.add(updated);
      }
    }
    return updatedList;
  }

  /// Reclassifies all messages in the database in streaming/paged chunks.
  ///
  /// Prevents holding the entire database in memory at once, enabling
  /// smooth processing for 10,000+ to 50,000+ messages.
  Future<int> reclassifyAllMessages({
    int batchSize = 100,
    void Function(int processed, int total)? onProgress,
  }) async {
    final total = await repository.getMessageCount();
    if (total == 0) {
      onProgress?.call(0, 0);
      return 0;
    }

    int offset = 0;
    int processedCount = 0;

    while (offset < total) {
      final batch = await repository.getMessagesPaged(
        limit: batchSize,
        offset: offset,
      );
      if (batch.isEmpty) break;

      final classifiedBatch = await classifyBatch(batch);
      await repository.insertMessages(classifiedBatch);

      processedCount += batch.length;
      offset += batch.length;
      onProgress?.call(processedCount > total ? total : processedCount, total);
    }

    return processedCount;
  }
}

/// Riverpod provider for ClassificationEngine.
final classificationEngineProvider = Provider<ClassificationEngine>((ref) {
  final metadataRepo = ref.watch(driftSenderMetadataRepositoryProvider);
  return ClassificationEngine(metadataRepository: metadataRepo);
});

/// Riverpod provider for MessageClassificationService.
final messageClassificationServiceProvider =
    Provider<MessageClassificationService>((ref) {
      final engine = ref.watch(classificationEngineProvider);
      final repo = ref.watch(driftMessageRepositoryProvider);

      return MessageClassificationService(engine: engine, repository: repo);
    });
