import 'dart:async';

import 'package:delmess/features/messages/data/sms_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier tracking the state and progress of SMS import/sync.
class SmsSyncNotifier extends Notifier<SmsSyncProgress> {
  StreamSubscription<SmsSyncProgress>? _sub;

  SmsSyncService get _syncService => ref.read(smsSyncServiceProvider);

  @override
  SmsSyncProgress build() {
    ref.onDispose(() => _sub?.cancel());
    _sub = _syncService.progressStream.listen((progress) {
      state = progress;
    });

    return const SmsSyncProgress(status: SmsSyncStatus.idle);
  }

  Future<void> startInitialSync({int batchSize = 100}) async {
    state = const SmsSyncProgress(status: SmsSyncStatus.inProgress);
    await _syncService.syncInitialMessages(
      batchSize: batchSize,
      onProgress: (p) {
        state = p;
      },
    );
  }

  Future<int> startIncrementalSync() async {
    return _syncService.syncIncrementalMessages();
  }
}

final smsSyncControllerProvider =
    NotifierProvider<SmsSyncNotifier, SmsSyncProgress>(() => SmsSyncNotifier());
