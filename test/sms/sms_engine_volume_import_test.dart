import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sms_sync_service.dart';
import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_sms_data_source.dart';
import '../helpers/fake_sms_permission_service.dart';

void main() {
  late AppDatabase db;
  late DriftMessageRepository repo;
  late FakeSmsPermissionService permissionService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftMessageRepository(db);
    permissionService = FakeSmsPermissionService(
      initialState: SmsPermissionState.granted,
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper to generate large volumes of synthetic SMS messages efficiently.
  List<RawSmsMessage> generateMessages(int count, {int startEpochMillis = 1756700000000}) {
    return List.generate(count, (index) {
      final id = 'sms_vol_$index';
      final threadId = 'thread_${index % 50}'; // realistic thread distribution
      final sender = (index % 3 == 0)
          ? 'AD-HDFCBK-T'
          : (index % 3 == 1 ? 'BZ-SWIGGY-P' : 'VK-AIRTEL-S');
      final body = 'Test message #$index with OTP ${1000 + (index % 9000)} for verification.';
      final timestamp = startEpochMillis + (index * 1000);

      return RawSmsMessage(
        id: id,
        threadId: threadId,
        sender: sender,
        body: body,
        receivedAtMillis: timestamp,
        isRead: index % 2 == 0,
      );
    });
  }

  group('Phase 5 — SMS Engine Message Importing Volume Tests', () {
    test('Empty inbox import completes successfully with 0 messages', () async {
      final dataSource = FakeSmsDataSource(initialMessages: []);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      final progressList = <SmsSyncProgress>[];
      await syncService.syncInitialMessages(
        onProgress: (p) => progressList.add(p),
      );

      final count = await repo.getMessageCount();
      expect(count, 0);
      expect(progressList.isNotEmpty, isTrue);
      expect(progressList.last.status, SmsSyncStatus.completed);
      expect(progressList.last.totalCount, 0);
      expect(progressList.last.processedCount, 0);

      syncService.dispose();
      dataSource.dispose();
    });

    test('100 SMS import verifies message integrity and pagination', () async {
      final msgs = generateMessages(100);
      final dataSource = FakeSmsDataSource(initialMessages: msgs);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      final progressList = <SmsSyncProgress>[];
      await syncService.syncInitialMessages(
        batchSize: 25,
        onProgress: (p) => progressList.add(p),
      );

      final totalStored = await repo.getMessageCount();
      expect(totalStored, 100);
      expect(progressList.last.status, SmsSyncStatus.completed);
      expect(progressList.last.processedCount, 100);

      // Verify sample messages
      final msg0 = await repo.getMessageById('sms_vol_0');
      expect(msg0, isNotNull);
      expect(msg0!.sender, 'AD-HDFCBK-T');

      final msg99 = await repo.getMessageById('sms_vol_99');
      expect(msg99, isNotNull);

      syncService.dispose();
      dataSource.dispose();
    });

    test('1,000 SMS import verifies thread grouping and batch progress', () async {
      final msgs = generateMessages(1000);
      final dataSource = FakeSmsDataSource(initialMessages: msgs);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      final progressList = <SmsSyncProgress>[];
      await syncService.syncInitialMessages(
        batchSize: 200,
        onProgress: (p) => progressList.add(p),
      );

      final totalStored = await repo.getMessageCount();
      expect(totalStored, 1000);
      expect(progressList.last.status, SmsSyncStatus.completed);
      expect(progressList.last.processedCount, 1000);

      // Verify thread messages
      final thread0Messages = await repo.getMessagesByThread('thread_0');
      expect(thread0Messages.isNotEmpty, isTrue);
      expect(thread0Messages.length, 20); // 1000 / 50 threads = 20 per thread

      syncService.dispose();
      dataSource.dispose();
    });

    test('10,000 SMS import stress test with high throughput', () async {
      final msgs = generateMessages(10000);
      final dataSource = FakeSmsDataSource(initialMessages: msgs);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      await syncService.syncInitialMessages(
        batchSize: 2000,
      );

      final totalStored = await repo.getMessageCount();
      expect(totalStored, 10000);

      // Check paged fetch
      final first50 = await repo.getMessagesPaged(limit: 50, offset: 0);
      expect(first50.length, 50);

      final last50 = await repo.getMessagesPaged(limit: 50, offset: 9950);
      expect(last50.length, 50);

      syncService.dispose();
      dataSource.dispose();
    });

    test('50,000 SMS import stress test under large scale', () async {
      final msgs = generateMessages(50000);
      final dataSource = FakeSmsDataSource(initialMessages: msgs);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      int lastProcessed = 0;
      await syncService.syncInitialMessages(
        batchSize: 5000,
        onProgress: (p) {
          lastProcessed = p.processedCount;
        },
      );

      expect(lastProcessed, 50000);
      final totalStored = await repo.getMessageCount();
      expect(totalStored, 50000);

      syncService.dispose();
      dataSource.dispose();
    });

    test('100,000+ SMS import (105,000 messages) high-volume scalability test', () async {
      const targetCount = 105000;
      final msgs = generateMessages(targetCount);
      final dataSource = FakeSmsDataSource(initialMessages: msgs);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      await syncService.syncInitialMessages(
        batchSize: 15000,
      );

      final totalStored = await repo.getMessageCount();
      expect(totalStored, targetCount);

      // Verify arbitrary boundary messages
      final startMsg = await repo.getMessageById('sms_vol_0');
      expect(startMsg, isNotNull);

      final midMsg = await repo.getMessageById('sms_vol_50000');
      expect(midMsg, isNotNull);

      final endMsg = await repo.getMessageById('sms_vol_104999');
      expect(endMsg, isNotNull);

      syncService.dispose();
      dataSource.dispose();
    });

    test('Very old SMS (epoch 0 / year 1999) importing and date preservation', () async {
      final oldMessages = [
        const RawSmsMessage(
          id: 'old_epoch_zero',
          threadId: 't_old',
          sender: 'AD-BSNL-T',
          body: 'Welcome to GSM mobile telephony service 1970.',
          receivedAtMillis: 0, // 1970-01-01
          isRead: true,
        ),
        const RawSmsMessage(
          id: 'old_1999',
          threadId: 't_old',
          sender: 'BPLMOBILE',
          body: 'Mid-1999 network readiness confirmed.',
          receivedAtMillis: 930000000000, // 1999-06-22
          isRead: true,
        ),
        const RawSmsMessage(
          id: 'old_2005',
          threadId: 't_old',
          sender: 'AIRTEL',
          body: 'Caller tunes service now active for Rs 30/month.',
          receivedAtMillis: 1104537600000, // 2005-01-01
          isRead: true,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: oldMessages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      await syncService.syncInitialMessages();

      final epochZeroMsg = await repo.getMessageById('old_epoch_zero');
      expect(epochZeroMsg, isNotNull);
      expect(epochZeroMsg!.receivedAt.millisecondsSinceEpoch, 0);

      final y1999Msg = await repo.getMessageById('old_1999');
      expect(y1999Msg, isNotNull);
      expect(y1999Msg!.receivedAt.year, 1999);

      final yr2005Msg = await repo.getMessageById('old_2005');
      expect(yr2005Msg, isNotNull);
      expect(yr2005Msg!.receivedAt.year, 2005);

      syncService.dispose();
      dataSource.dispose();
    });

    test('Very recent SMS (current millisecond & future) importing', () async {
      final now = DateTime.now();
      final nowMillis = now.millisecondsSinceEpoch;
      final recentMessages = [
        RawSmsMessage(
          id: 'recent_now',
          threadId: 't_recent',
          sender: 'AD-HDFCBK-T',
          body: 'Instant OTP 849201 generated right now.',
          receivedAtMillis: nowMillis,
          isRead: false,
        ),
        RawSmsMessage(
          id: 'recent_subsecond_1',
          threadId: 't_recent',
          sender: 'AD-HDFCBK-T',
          body: 'Your transaction of Rs 250 is successful.',
          receivedAtMillis: nowMillis + 5000,
          isRead: false,
        ),
        RawSmsMessage(
          id: 'recent_future_scheduled',
          threadId: 't_recent',
          sender: 'COWIN',
          body: 'Scheduled booster reminder for tomorrow.',
          receivedAtMillis: nowMillis + 86400000, // +24 hours ahead
          isRead: false,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: recentMessages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      await syncService.syncInitialMessages();

      final nowMsg = await repo.getMessageById('recent_now');
      expect(nowMsg, isNotNull);
      expect(
        (nowMsg!.receivedAt.difference(now).inSeconds).abs() <= 2,
        isTrue,
        reason: 'Message timestamp should match current time within second precision',
      );

      final futureMsg = await repo.getMessageById('recent_future_scheduled');
      expect(futureMsg, isNotNull);
      expect(futureMsg!.receivedAt.isAfter(DateTime.now()), isTrue);

      syncService.dispose();
      dataSource.dispose();
    });
  });
}
