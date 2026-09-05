import 'dart:async';

import 'package:delmess/core/database/database_providers.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/classification/domain/message_classification_service.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sms_data_source.dart';
import 'package:delmess/features/messages/data/sms_normalizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SmsSyncStatus { idle, inProgress, completed, error }

class SmsSyncProgress {
  final int totalCount;
  final int processedCount;
  final SmsSyncStatus status;
  final String? errorMessage;

  const SmsSyncProgress({
    this.totalCount = 0,
    this.processedCount = 0,
    this.status = SmsSyncStatus.idle,
    this.errorMessage,
  });

  double get progressFraction {
    if (totalCount <= 0) return status == SmsSyncStatus.completed ? 1.0 : 0.0;
    return (processedCount / totalCount).clamp(0.0, 1.0);
  }

  SmsSyncProgress copyWith({
    int? totalCount,
    int? processedCount,
    SmsSyncStatus? status,
    String? errorMessage,
  }) {
    return SmsSyncProgress(
      totalCount: totalCount ?? this.totalCount,
      processedCount: processedCount ?? this.processedCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SmsSyncService {
  final SmsDataSource dataSource;
  final MessageRepository messageRepo;
  final SmsPermissionService permissionService;
  final MessageClassificationService? classificationService;

  StreamSubscription? _incomingSubscription;
  final StreamController<SmsSyncProgress> _progressController =
      StreamController<SmsSyncProgress>.broadcast();

  SmsSyncService({
    required this.dataSource,
    required this.messageRepo,
    required this.permissionService,
    this.classificationService,
  });

  Stream<SmsSyncProgress> get progressStream => _progressController.stream;

  /// Starts initial bulk sync of SMS messages in batches.
  Future<void> syncInitialMessages({
    int batchSize = 100,
    void Function(SmsSyncProgress)? onProgress,
  }) async {
    try {
      final perm = await permissionService.getPermissionState();
      if (perm != SmsPermissionState.granted) {
        final reqResult = await permissionService.requestSmsPermission();
        if (reqResult != SmsPermissionState.granted) {
          final errProgress = const SmsSyncProgress(
            status: SmsSyncStatus.error,
            errorMessage: 'SMS permission not granted',
          );
          _reportProgress(errProgress, onProgress);
          return;
        }
      }

      final total = await dataSource.getSmsCount();
      if (total == 0) {
        final doneProgress = const SmsSyncProgress(
          totalCount: 0,
          processedCount: 0,
          status: SmsSyncStatus.completed,
        );
        _reportProgress(doneProgress, onProgress);
        return;
      }

      var progress = SmsSyncProgress(
        totalCount: total,
        processedCount: 0,
        status: SmsSyncStatus.inProgress,
      );
      _reportProgress(progress, onProgress);

      int offset = 0;
      while (offset < total) {
        final rawBatch = await dataSource.getSmsBatch(
          limit: batchSize,
          offset: offset,
        );

        if (rawBatch.isEmpty) break;

        final normalizedBatch = SmsNormalizer.normalizeBatch(rawBatch);
        final batchToInsert = classificationService != null
            ? await classificationService!.classifyBatch(normalizedBatch)
            : normalizedBatch;
        await messageRepo.insertMessages(batchToInsert);

        offset += rawBatch.length;
        progress = progress.copyWith(
          processedCount: offset > total ? total : offset,
        );
        _reportProgress(progress, onProgress);
      }

      // Ensure any existing messages are safely reclassified to the latest rule version
      await classificationService?.reclassifyIfNeeded();

      final completed = progress.copyWith(
        processedCount: total,
        status: SmsSyncStatus.completed,
      );
      _reportProgress(completed, onProgress);
    } catch (e) {
      final err = SmsSyncProgress(
        status: SmsSyncStatus.error,
        errorMessage: 'Sync failed: $e',
      );
      _reportProgress(err, onProgress);
    }
  }

  /// Incremental sync for new messages received while app was closed.
  Future<int> syncIncrementalMessages({int batchSize = 100}) async {
    try {
      final allMessages = await messageRepo.getAllMessages();
      DateTime? latestDate;
      if (allMessages.isNotEmpty) {
        latestDate = allMessages
            .map((m) => m.receivedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }

      int totalImported = 0;
      int offset = 0;
      while (true) {
        final rawBatch = await dataSource.getSmsBatch(
          limit: batchSize,
          offset: offset,
          since: latestDate,
        );

        if (rawBatch.isEmpty) break;

        final normalized = SmsNormalizer.normalizeBatch(rawBatch);
        final batchToInsert = classificationService != null
            ? await classificationService!.classifyBatch(normalized)
            : normalized;
        await messageRepo.insertMessages(batchToInsert);
        totalImported += batchToInsert.length;
        offset += rawBatch.length;

        if (rawBatch.length < batchSize) break;
      }

      // Ensure any older messages are safely upgraded to the latest classification rules
      await classificationService?.reclassifyIfNeeded();

      return totalImported;
    } catch (_) {
      return 0;
    }
  }

  /// Reprocesses and reclassifies all messages in the database.
  Future<int> reprocessAndClassifyAll() async {
    if (classificationService == null) return 0;
    return classificationService!.reclassifyAllMessages();
  }

  /// Subscribes to real-time incoming SMS events and immediately persists them to SQLite.
  void listenToIncomingSms() {
    _incomingSubscription?.cancel();
    _incomingSubscription = dataSource.incomingSmsStream.listen(
      (rawMsg) async {
        try {
          final normalized = SmsNormalizer.normalize(rawMsg);
          final msgToInsert = classificationService != null
              ? await classificationService!.classifyMessage(normalized)
              : normalized;
          await messageRepo.insertMessage(msgToInsert);
        } catch (_) {
          // Skip malformed incoming message safely
        }
      },
      onError: (_) {
        // Safe error handling
      },
    );
  }

  void _reportProgress(
    SmsSyncProgress progress,
    void Function(SmsSyncProgress)? callback,
  ) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
    callback?.call(progress);
  }

  void dispose() {
    _incomingSubscription?.cancel();
    _progressController.close();
  }
}

/// Provider for SmsSyncService.
final smsSyncServiceProvider = Provider<SmsSyncService>((ref) {
  final dataSource = ref.watch(smsDataSourceProvider);
  final messageRepo = ref.watch(driftMessageRepositoryProvider);
  final permissionService = ref.watch(smsPermissionServiceProvider);
  final classificationService = ref.watch(messageClassificationServiceProvider);

  final service = SmsSyncService(
    dataSource: dataSource,
    messageRepo: messageRepo,
    permissionService: permissionService,
    classificationService: classificationService,
  );

  ref.onDispose(() => service.dispose());
  return service;
});
