import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sms_data_source.dart';
import 'package:delmess/features/messages/data/sms_sync_service.dart';
import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftMessageRepository repo;
  late FakeSmsDataSource dataSource;
  late FakeSmsPermissionService permissionService;
  late SmsSyncService syncService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftMessageRepository(db);
    permissionService = FakeSmsPermissionService(
      initialState: SmsPermissionState.granted,
    );
    dataSource = FakeSmsDataSource();
    syncService = SmsSyncService(
      dataSource: dataSource,
      messageRepo: repo,
      permissionService: permissionService,
    );
  });

  tearDown(() async {
    syncService.dispose();
    await db.close();
  });

  group('SmsSyncService Integration & Idempotency Tests', () {
    test(
      'initial batch sync imports messages into database with progress reporting',
      () async {
        final progressEvents = <SmsSyncProgress>[];
        await syncService.syncInitialMessages(
          batchSize: 2,
          onProgress: (p) => progressEvents.add(p),
        );

        final storedMessages = await repo.getAllMessages();
        expect(storedMessages.length, 3);
        expect(progressEvents.isNotEmpty, true);
        expect(progressEvents.last.status, SmsSyncStatus.completed);
        expect(progressEvents.last.processedCount, 3);
        expect(progressEvents.last.totalCount, 3);
      },
    );

    test(
      'sync is strictly idempotent - running twice does not create duplicate messages',
      () async {
        // First sync
        await syncService.syncInitialMessages(batchSize: 2);
        var stored = await repo.getAllMessages();
        expect(stored.length, 3);

        // Second sync
        await syncService.syncInitialMessages(batchSize: 2);
        stored = await repo.getAllMessages();
        expect(
          stored.length,
          3,
          reason: 'Duplicate messages must NOT be created',
        );
      },
    );

    test(
      'incremental sync only imports new messages received after the latest timestamp',
      () async {
        await syncService.syncInitialMessages();
        var stored = await repo.getAllMessages();
        expect(stored.length, 3);

        // Simulate a brand new message received on the device
        const newMsg = RawSmsMessage(
          id: 'fake_new_4',
          threadId: 'thread_bank',
          sender: 'AD-SBIBNK-T',
          body: 'Rs 500 credited to account.',
          receivedAtMillis: 1756740000000,
          isRead: false,
        );
        dataSource.addMessage(newMsg);

        final importedCount = await syncService.syncIncrementalMessages();
        expect(importedCount, 1);

        stored = await repo.getAllMessages();
        expect(stored.length, 4);
      },
    );

    test('fails gracefully when permission is denied', () async {
      final deniedPermService = FakeSmsPermissionService(
        initialState: SmsPermissionState.denied,
        autoGrant: false,
      );
      final testSyncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: deniedPermService,
      );

      final progressEvents = <SmsSyncProgress>[];
      await testSyncService.syncInitialMessages(
        onProgress: (p) => progressEvents.add(p),
      );

      final stored = await repo.getAllMessages();
      expect(stored.isEmpty, true);
    });

    test('real-time incoming SMS updates database immediately', () async {
      syncService.listenToIncomingSms();

      final incoming = RawSmsMessage(
        id: 'incoming_1',
        threadId: 'thread_live',
        sender: 'VK-AIRTEL-S',
        body: 'Recharge successful for Rs 299.',
        receivedAtMillis: DateTime.now().millisecondsSinceEpoch,
        isRead: false,
      );

      dataSource.emitIncoming(incoming);
      // Allow async event loop to process
      await Future.delayed(const Duration(milliseconds: 50));

      final msg = await repo.getMessageById('incoming_1');
      expect(msg, isNotNull);
      expect(msg!.sender, 'VK-AIRTEL-S');
      expect(msg.body, 'Recharge successful for Rs 299.');
    });
  });
}
