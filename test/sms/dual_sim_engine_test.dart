import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sms_sync_service.dart';
import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:delmess/features/sim/domain/dual_sim_service.dart';
import 'package:delmess/features/sim/domain/sim_info.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_sms_data_source.dart';
import '../helpers/fake_sms_permission_service.dart';

void main() {
  late AppDatabase db;
  late DriftMessageRepository repo;
  late FakeSmsPermissionService permissionService;
  late DualSimService dualSimService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftMessageRepository(db);
    permissionService = FakeSmsPermissionService(
      initialState: SmsPermissionState.granted,
    );
    dualSimService = DualSimService(
      initialSims: [
        const SimInfo(
          subscriptionId: 1,
          slotIndex: 0,
          displayName: 'SIM 1 (Jio)',
          carrierName: 'Jio',
          isDefaultData: true,
          isDefaultSms: true,
          isActive: true,
        ),
        const SimInfo(
          subscriptionId: 2,
          slotIndex: 1,
          displayName: 'SIM 2 (Airtel)',
          carrierName: 'Airtel',
          isDefaultData: false,
          isDefaultSms: false,
          isActive: true,
        ),
      ],
    );
  });

  tearDown(() async {
    dualSimService.dispose();
    await db.close();
  });

  group('Phase 6 — Dual-SIM Engine Testing', () {
    // -------------------------------------------------------------------------
    // 1. SIM 1 SMS & SIM 2 SMS
    // -------------------------------------------------------------------------
    test('SIM 1 SMS importing, slot assignment, and querying', () async {
      final sim1Messages = [
        const RawSmsMessage(
          id: 'sim1_msg_1',
          threadId: 't_s1_1',
          sender: 'AD-HDFCBK-T',
          body: 'Salary credited to A/C **1111 on SIM 1.',
          receivedAtMillis: 1756700000000,
          subId: 1,
          simSlot: 0,
          carrierName: 'Jio',
        ),
        const RawSmsMessage(
          id: 'sim1_msg_2',
          threadId: 't_s1_2',
          sender: 'JM-JIOINF-S',
          body: 'Your 2GB daily data pack on SIM 1 is 50% consumed.',
          receivedAtMillis: 1756700010000,
          subId: 1,
          simSlot: 0,
          carrierName: 'Jio',
        ),
      ];

      final sim = await dualSimService.getSimBySlot(0);
      expect(sim, isNotNull);
      expect(sim!.slotIndex, 0);
      expect(sim.carrierName, 'Jio');
      expect(sim.isDefaultSms, isTrue);

      final filtered = dualSimService.filterMessagesBySim(sim1Messages, 0);
      expect(filtered.length, 2);
      expect(filtered.every((m) => m.simSlot == 0), isTrue);

      // Verify saving to database
      final dataSource = FakeSmsDataSource(initialMessages: sim1Messages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      await syncService.syncInitialMessages();
      final stored = await repo.getMessageById('sim1_msg_1');
      expect(stored, isNotNull);
      expect(stored!.sender, 'AD-HDFCBK-T');

      syncService.dispose();
      dataSource.dispose();
    });

    test('SIM 2 SMS importing, slot assignment, and querying', () async {
      final sim2Messages = [
        const RawSmsMessage(
          id: 'sim2_msg_1',
          threadId: 't_s2_1',
          sender: 'VK-AIRTEL-S',
          body: 'SIM 2 recharge of Rs 299 successful.',
          receivedAtMillis: 1756700020000,
          subId: 2,
          simSlot: 1,
          carrierName: 'Airtel',
        ),
        const RawSmsMessage(
          id: 'sim2_msg_2',
          threadId: 't_s2_2',
          sender: 'AD-SBIBNK-T',
          body: 'OTP 891234 for SIM 2 personal card transaction.',
          receivedAtMillis: 1756700030000,
          subId: 2,
          simSlot: 1,
          carrierName: 'Airtel',
        ),
      ];

      final sim = await dualSimService.getSimBySlot(1);
      expect(sim, isNotNull);
      expect(sim!.slotIndex, 1);
      expect(sim.carrierName, 'Airtel');

      final filtered = dualSimService.filterMessagesBySim(sim2Messages, 1);
      expect(filtered.length, 2);
      expect(filtered.every((m) => m.simSlot == 1), isTrue);

      final dataSource = FakeSmsDataSource(initialMessages: sim2Messages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      await syncService.syncInitialMessages();
      final stored = await repo.getMessageById('sim2_msg_1');
      expect(stored, isNotNull);
      expect(stored!.sender, 'VK-AIRTEL-S');

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 2. Incoming SMS on SIM 1 & SIM 2
    // -------------------------------------------------------------------------
    test('Incoming SMS on SIM 1 delivers via stream with slot 0 and subId 1', () async {
      final dataSource = FakeSmsDataSource(initialMessages: []);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );
      syncService.listenToIncomingSms();

      const incomingSim1 = RawSmsMessage(
        id: 'inc_sim1_live',
        threadId: 't_inc_s1',
        sender: 'AD-ICICIB-T',
        body: 'SIM 1: INR 1,200 debited from A/C **5555.',
        receivedAtMillis: 1756700050000,
        subId: 1,
        simSlot: 0,
        carrierName: 'Jio',
      );

      dataSource.emitIncoming(incomingSim1);
      await Future.delayed(const Duration(milliseconds: 50));

      final stored = await repo.getMessageById('inc_sim1_live');
      expect(stored, isNotNull);
      expect(stored!.sender, 'AD-ICICIB-T');

      final simInfo = await dualSimService.getSimBySubscriptionId(incomingSim1.subId!);
      expect(simInfo, isNotNull);
      expect(simInfo!.slotIndex, 0);
      expect(simInfo.carrierName, 'Jio');

      syncService.dispose();
      dataSource.dispose();
    });

    test('Incoming SMS on SIM 2 delivers via stream with slot 1 and subId 2', () async {
      final dataSource = FakeSmsDataSource(initialMessages: []);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );
      syncService.listenToIncomingSms();

      const incomingSim2 = RawSmsMessage(
        id: 'inc_sim2_live',
        threadId: 't_inc_s2',
        sender: 'BZ-SWIGGY-P',
        body: 'SIM 2: Craving Pizza? Flat 50% OFF today!',
        receivedAtMillis: 1756700060000,
        subId: 2,
        simSlot: 1,
        carrierName: 'Airtel',
      );

      dataSource.emitIncoming(incomingSim2);
      await Future.delayed(const Duration(milliseconds: 50));

      final stored = await repo.getMessageById('inc_sim2_live');
      expect(stored, isNotNull);
      expect(stored!.sender, 'BZ-SWIGGY-P');

      final simInfo = await dualSimService.getSimBySubscriptionId(incomingSim2.subId!);
      expect(simInfo, isNotNull);
      expect(simInfo!.slotIndex, 1);
      expect(simInfo.carrierName, 'Airtel');

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 3. Different carriers (Jio, Airtel, Vi, BSNL)
    // -------------------------------------------------------------------------
    test('Different carriers combination (Jio + Airtel, Vi + BSNL)', () async {
      final multiCarrierMessages = [
        const RawSmsMessage(
          id: 'jio_msg',
          threadId: 't_jio',
          sender: 'JM-JIOINF-S',
          body: 'Jio Welcome Offer active on SIM 1.',
          receivedAtMillis: 1756700000000,
          subId: 1,
          simSlot: 0,
          carrierName: 'Jio',
        ),
        const RawSmsMessage(
          id: 'airtel_msg',
          threadId: 't_airtel',
          sender: 'VK-AIRTEL-S',
          body: 'Airtel 5G Plus is active on SIM 2.',
          receivedAtMillis: 1756700010000,
          subId: 2,
          simSlot: 1,
          carrierName: 'Airtel',
        ),
        const RawSmsMessage(
          id: 'vi_msg',
          threadId: 't_vi',
          sender: 'VD-VODAIN-S',
          body: 'Vi Hero Unlimited data benefits now active.',
          receivedAtMillis: 1756700020000,
          subId: 3,
          simSlot: 0,
          carrierName: 'Vi',
        ),
        const RawSmsMessage(
          id: 'bsnl_msg',
          threadId: 't_bsnl',
          sender: 'AD-BSNL-S',
          body: 'BSNL 4G service connection established.',
          receivedAtMillis: 1756700030000,
          subId: 4,
          simSlot: 1,
          carrierName: 'BSNL',
        ),
      ];

      final jioList = dualSimService.filterMessagesByCarrier(multiCarrierMessages, 'Jio');
      expect(jioList.length, 1);
      expect(jioList.first.id, 'jio_msg');

      final airtelList = dualSimService.filterMessagesByCarrier(multiCarrierMessages, 'Airtel');
      expect(airtelList.length, 1);
      expect(airtelList.first.id, 'airtel_msg');

      final viList = dualSimService.filterMessagesByCarrier(multiCarrierMessages, 'Vi');
      expect(viList.length, 1);
      expect(viList.first.id, 'vi_msg');

      final bsnlList = dualSimService.filterMessagesByCarrier(multiCarrierMessages, 'BSNL');
      expect(bsnlList.length, 1);
      expect(bsnlList.first.id, 'bsnl_msg');
    });

    // -------------------------------------------------------------------------
    // 4. SIM removed
    // -------------------------------------------------------------------------
    test('SIM removed handles slot ejection gracefully without data loss', () async {
      final events = <SimStateEvent>[];
      final subscription = dualSimService.simEventsStream.listen(events.add);

      // Verify 2 active SIMs initially
      var activeSims = await dualSimService.getActiveSims();
      expect(activeSims.length, 2);

      // Simulate SIM 2 removal (tray ejected)
      dualSimService.handleSimRemoval(1);

      activeSims = await dualSimService.getActiveSims();
      expect(activeSims.length, 1);
      expect(activeSims.first.slotIndex, 0);

      final sim2 = await dualSimService.getSimBySlot(1);
      expect(sim2, isNotNull);
      expect(sim2!.isActive, isFalse);
      expect(sim2.simState, SimCardState.absent);

      expect(events.length, 1);
      expect(events.first.type, SimStateEventType.removed);
      expect(events.first.slotIndex, 1);

      await subscription.cancel();
    });

    // -------------------------------------------------------------------------
    // 5. SIM replaced
    // -------------------------------------------------------------------------
    test('SIM replaced updates carrier metadata and retains message history', () async {
      final events = <SimStateEvent>[];
      final subscription = dualSimService.simEventsStream.listen(events.add);

      const newSim2 = SimInfo(
        subscriptionId: 10,
        slotIndex: 1,
        displayName: 'SIM 2 (Vi)',
        carrierName: 'Vi',
        isDefaultData: false,
        isDefaultSms: false,
        isActive: true,
      );

      // Replace SIM 2 Airtel with new SIM 2 Vi
      dualSimService.handleSimReplacement(1, newSim2);

      final updatedSim2 = await dualSimService.getSimBySlot(1);
      expect(updatedSim2, isNotNull);
      expect(updatedSim2!.carrierName, 'Vi');
      expect(updatedSim2.subscriptionId, 10);

      expect(events.length, 1);
      expect(events.first.type, SimStateEventType.replaced);
      expect(events.first.slotIndex, 1);
      expect(events.first.previousSimInfo?.carrierName, 'Airtel');
      expect(events.first.simInfo?.carrierName, 'Vi');

      await subscription.cancel();
    });

    // -------------------------------------------------------------------------
    // 6. Default SIM changed
    // -------------------------------------------------------------------------
    test('Default SIM changed switches default SMS slot and emits event', () async {
      final events = <SimStateEvent>[];
      final subscription = dualSimService.simEventsStream.listen(events.add);

      var defaultSim = await dualSimService.getDefaultSmsSim();
      expect(defaultSim, isNotNull);
      expect(defaultSim!.slotIndex, 0); // Initially SIM 1

      // User switches default SMS SIM in Android Settings to SIM 2
      final success = await dualSimService.setDefaultSmsSim(1);
      expect(success, isTrue);

      defaultSim = await dualSimService.getDefaultSmsSim();
      expect(defaultSim, isNotNull);
      expect(defaultSim!.slotIndex, 1);
      expect(defaultSim.carrierName, 'Airtel');
      expect(defaultSim.isDefaultSms, isTrue);

      final sim1 = await dualSimService.getSimBySlot(0);
      expect(sim1!.isDefaultSms, isFalse);

      expect(events.length, 1);
      expect(events.first.type, SimStateEventType.defaultChanged);
      expect(events.first.slotIndex, 1);

      await subscription.cancel();
    });

    // -------------------------------------------------------------------------
    // 7. Phone reboot with dual SIM
    // -------------------------------------------------------------------------
    test('Phone reboot restores dual SIM state and preserves database', () async {
      // 1. Insert SMS messages into SQLite database prior to reboot
      final preRebootMsg = const RawSmsMessage(
        id: 'msg_pre_reboot',
        threadId: 't_reboot',
        sender: 'AD-HDFCBK-T',
        body: 'Pre-reboot banking alert on SIM 1.',
        receivedAtMillis: 1756700000000,
        subId: 1,
        simSlot: 0,
        carrierName: 'Jio',
      );

      final dataSource = FakeSmsDataSource(initialMessages: [preRebootMsg]);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
      );

      await syncService.syncInitialMessages();
      expect(await repo.getMessageCount(), 1);

      // 2. Simulate phone reboot (BOOT_COMPLETED broadcast received)
      final events = <SimStateEvent>[];
      final subscription = dualSimService.simEventsStream.listen(events.add);

      dualSimService.handleDeviceReboot([
        const SimInfo(
          subscriptionId: 1,
          slotIndex: 0,
          displayName: 'SIM 1',
          carrierName: 'Jio',
          isDefaultData: true,
          isDefaultSms: true,
          isActive: true,
        ),
        const SimInfo(
          subscriptionId: 2,
          slotIndex: 1,
          displayName: 'SIM 2',
          carrierName: 'Airtel',
          isDefaultData: false,
          isDefaultSms: false,
          isActive: true,
        ),
      ]);

      // 3. Verify SQLite data is preserved across reboot
      final stored = await repo.getMessageById('msg_pre_reboot');
      expect(stored, isNotNull);
      expect(stored!.sender, 'AD-HDFCBK-T');

      // 4. Verify dual-SIM subscriptions are re-initialized
      final activeSims = await dualSimService.getActiveSims();
      expect(activeSims.length, 2);
      expect(events.length, 2);
      expect(events.every((e) => e.type == SimStateEventType.rebootRestored), isTrue);

      syncService.dispose();
      dataSource.dispose();
      await subscription.cancel();
    });
  });
}
