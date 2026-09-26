import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/core/services/sms_permission_service.dart';
import 'package:delmess/features/classification/domain/classification_engine.dart';
import 'package:delmess/features/classification/domain/message_classification_service.dart';
import 'package:delmess/features/classification/domain/sms_header_parser.dart';
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
  late ClassificationEngine classificationEngine;
  late MessageClassificationService classificationService;
  late SmsHeaderParser headerParser;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftMessageRepository(db);
    permissionService = FakeSmsPermissionService(
      initialState: SmsPermissionState.granted,
    );
    headerParser = const SmsHeaderParser();
    classificationEngine = ClassificationEngine();
    classificationService = MessageClassificationService(
      engine: classificationEngine,
      repository: repo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Phase 5 — SMS Engine SMS Formats Testing', () {
    // -------------------------------------------------------------------------
    // 1. Normal numeric sender
    // -------------------------------------------------------------------------
    test('Normal numeric sender (10-digit mobile) parsing and import', () async {
      const raw = RawSmsMessage(
        id: 'msg_numeric_1',
        threadId: 't_numeric_1',
        sender: '9876543210',
        body: 'Hey, are we still meeting today at 5 PM?',
        receivedAtMillis: 1756700000000,
        isRead: false,
      );

      final parsed = headerParser.parse(raw.sender);
      expect(parsed.isCommercial, isFalse);
      expect(parsed.cleanHeader, '9876543210');
      expect(parsed.operatorPrefix, isNull);
      expect(parsed.suffix, isNull);

      final dataSource = FakeSmsDataSource(initialMessages: [raw]);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();
      final stored = await repo.getMessageById('msg_numeric_1');
      expect(stored, isNotNull);
      expect(stored!.sender, '9876543210');
      expect(stored.category, CategoryType.other);

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 2. Alphanumeric sender
    // -------------------------------------------------------------------------
    test('Alphanumeric sender (TRAI commercial headers and bare brand headers)', () async {
      final messages = [
        const RawSmsMessage(
          id: 'alpha_trai_1',
          threadId: 't_alpha_1',
          sender: 'AD-HDFCBK-T',
          body: 'INR 5,000.00 debited from A/C **1234 on 01-Jan-26.',
          receivedAtMillis: 1756700000000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'alpha_trai_2',
          threadId: 't_alpha_2',
          sender: 'VM-AMAZON-P',
          body: 'Great Indian Festival: Flat 40% OFF on Electronics!',
          receivedAtMillis: 1756700010000,
          isRead: true,
        ),
        const RawSmsMessage(
          id: 'alpha_bare_1',
          threadId: 't_alpha_3',
          sender: 'SWIGGY',
          body: 'Your food order #9281 has been picked up.',
          receivedAtMillis: 1756700020000,
          isRead: true,
        ),
        const RawSmsMessage(
          id: 'alpha_service_1',
          threadId: 't_alpha_4',
          sender: 'JD-JIOINF-S',
          body: 'Your 1.5GB daily data voucher is now active.',
          receivedAtMillis: 1756700030000,
          isRead: true,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: messages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();

      final hdfcMsg = await repo.getMessageById('alpha_trai_1');
      expect(hdfcMsg, isNotNull);
      expect(hdfcMsg!.header, 'HDFCBK');
      expect(hdfcMsg.operatorPrefix, 'AD');
      expect(hdfcMsg.messageTypeSuffix, 'T');
      expect(hdfcMsg.category, CategoryType.transactional);

      final amzMsg = await repo.getMessageById('alpha_trai_2');
      expect(amzMsg, isNotNull);
      expect(amzMsg!.header, 'AMAZON');
      expect(amzMsg.operatorPrefix, 'VM');
      expect(amzMsg.messageTypeSuffix, 'P');
      expect(amzMsg.category, CategoryType.promotional);

      final swiggyMsg = await repo.getMessageById('alpha_bare_1');
      expect(swiggyMsg, isNotNull);
      expect(swiggyMsg!.header, 'SWIGGY');
      expect(swiggyMsg.category, CategoryType.service);

      final jioMsg = await repo.getMessageById('alpha_service_1');
      expect(jioMsg, isNotNull);
      expect(jioMsg!.header, 'JIOINF');
      expect(jioMsg.messageTypeSuffix, 'S');
      expect(jioMsg.category, CategoryType.service);

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 3. Short codes
    // -------------------------------------------------------------------------
    test('Short codes (3 to 8 digits e.g. 121, 198, 56161, 54321)', () async {
      final shortCodes = ['121', '198', '1901', '56161', '54321'];

      for (int i = 0; i < shortCodes.length; i++) {
        final code = shortCodes[i];
        final raw = RawSmsMessage(
          id: 'sc_$code',
          threadId: 't_sc_$code',
          sender: code,
          body: 'Service alert from short code $code.',
          receivedAtMillis: 1756700000000 + (i * 1000),
          isRead: true,
        );

        final parsed = headerParser.parse(code);
        expect(parsed.cleanHeader, code);
        expect(parsed.isCommercial, isFalse);

        final dataSource = FakeSmsDataSource(initialMessages: [raw]);
        final syncService = SmsSyncService(
          dataSource: dataSource,
          messageRepo: repo,
          permissionService: permissionService,
          classificationService: classificationService,
        );

        await syncService.syncInitialMessages();
        final stored = await repo.getMessageById('sc_$code');
        expect(stored, isNotNull);
        expect(stored!.sender, code);
        expect(stored.header, code);

        syncService.dispose();
        dataSource.dispose();
      }
    });

    // -------------------------------------------------------------------------
    // 4. +91 numbers
    // -------------------------------------------------------------------------
    test('+91 numbers (standard, spaced, hyphens) parsing and storage', () async {
      final numbers = [
        '+919876543210',
        '+91 98765 43210',
        '+91-98765-43210',
      ];

      for (int i = 0; i < numbers.length; i++) {
        final numStr = numbers[i];
        final id = 'msg_ind_$i';
        final raw = RawSmsMessage(
          id: id,
          threadId: 't_ind_$i',
          sender: numStr,
          body: 'Hello from domestic mobile number $numStr',
          receivedAtMillis: 1756700000000 + (i * 1000),
          isRead: false,
        );

        final parsed = headerParser.parse(numStr);
        expect(parsed.cleanHeader, '9876543210');
        expect(parsed.isCommercial, isFalse);

        final dataSource = FakeSmsDataSource(initialMessages: [raw]);
        final syncService = SmsSyncService(
          dataSource: dataSource,
          messageRepo: repo,
          permissionService: permissionService,
          classificationService: classificationService,
        );

        await syncService.syncInitialMessages();
        final stored = await repo.getMessageById(id);
        expect(stored, isNotNull);
        expect(stored!.rawSender, numStr);
        expect(stored.header, '9876543210');

        syncService.dispose();
        dataSource.dispose();
      }
    });

    // -------------------------------------------------------------------------
    // 5. International numbers
    // -------------------------------------------------------------------------
    test('International numbers (+1 US, +44 UK, +61 AU, formatted)', () async {
      final intlNumbers = [
        '+14155552671', // US
        '+447911123456', // UK
        '+61412345678', // Australia
        '+1 (415) 555-2671', // US formatted with parentheses
      ];

      for (int i = 0; i < intlNumbers.length; i++) {
        final intlNum = intlNumbers[i];
        final id = 'msg_intl_$i';
        final raw = RawSmsMessage(
          id: id,
          threadId: 't_intl_$i',
          sender: intlNum,
          body: 'International verification notification from $intlNum',
          receivedAtMillis: 1756700000000 + (i * 1000),
          isRead: true,
        );

        final parsed = headerParser.parse(intlNum);
        expect(parsed.isCommercial, isFalse);
        expect(parsed.cleanHeader.isNotEmpty, isTrue);

        final dataSource = FakeSmsDataSource(initialMessages: [raw]);
        final syncService = SmsSyncService(
          dataSource: dataSource,
          messageRepo: repo,
          permissionService: permissionService,
          classificationService: classificationService,
        );

        await syncService.syncInitialMessages();
        final stored = await repo.getMessageById(id);
        expect(stored, isNotNull);
        expect(stored!.rawSender, intlNum);

        syncService.dispose();
        dataSource.dispose();
      }
    });

    // -------------------------------------------------------------------------
    // 6. Multipart SMS
    // -------------------------------------------------------------------------
    test('Multipart SMS (concatenated multi-segment 500+ and 1200+ chars)', () async {
      final longBody500 = '''
Dear Customer, Your Home Loan Account No. 981273912 has been successfully sanctioned for Rs 45,00,000.00. 
The terms of the sanction include a floating interest rate of 8.40% p.a. with an EMI of Rs 38,750.00 payable 
on the 5th of every calendar month. Please submit the physical documentation and signed agreements at your nearest branch 
within 15 working days. For loan agreement details and status tracking, visit our portal or contact your relationship manager.
'''.trim();

      final longBody1200 = longBody500 * 3; // ~1300+ characters multi-part

      final multipartMessages = [
        RawSmsMessage(
          id: 'multipart_1',
          threadId: 't_multi',
          sender: 'AD-SBIBNK-T',
          body: longBody500,
          receivedAtMillis: 1756700000000,
          isRead: false,
        ),
        RawSmsMessage(
          id: 'multipart_2',
          threadId: 't_multi',
          sender: 'AD-SBIBNK-T',
          body: longBody1200,
          receivedAtMillis: 1756700010000,
          isRead: false,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: multipartMessages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();

      final stored500 = await repo.getMessageById('multipart_1');
      expect(stored500, isNotNull);
      expect(stored500!.body, longBody500);
      expect(stored500.category, CategoryType.transactional);

      final stored1200 = await repo.getMessageById('multipart_2');
      expect(stored1200, isNotNull);
      expect(stored1200!.body.length, greaterThan(1000));
      expect(stored1200.body, longBody1200);
      expect(stored1200.category, CategoryType.transactional);

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 7. Unicode SMS
    // -------------------------------------------------------------------------
    test('Unicode SMS (currencies ₹, €, \$, £, symbols ©, ™, em dash, smart quotes)', () async {
      const unicodeBody = 'Payment received: ₹1,500.00 (€18.50 / \$20.00 / £16.20). '
          '“DelMess™ © 2026 — All Rights Reserved”. Bal: ₹45,210.00 • Status: Active';

      const raw = RawSmsMessage(
        id: 'unicode_msg_1',
        threadId: 't_unicode',
        sender: 'AX-ICICIB-T',
        body: unicodeBody,
        receivedAtMillis: 1756700000000,
        isRead: true,
      );

      final dataSource = FakeSmsDataSource(initialMessages: [raw]);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();
      final stored = await repo.getMessageById('unicode_msg_1');
      expect(stored, isNotNull);
      expect(stored!.body, unicodeBody);
      expect(stored.body.contains('₹'), isTrue);
      expect(stored.body.contains('€'), isTrue);
      expect(stored.body.contains('™'), isTrue);
      expect(stored.body.contains('©'), isTrue);
      expect(stored.body.contains('—'), isTrue);

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 8. Emoji
    // -------------------------------------------------------------------------
    test('Emoji (Standard, ZWJ sequences, skin tones, and country flags)', () async {
      const emojiBody =
          '🎉 Congratulations! Your food order is on its way 🍔🛵💨! '
          'Delivering to your family 👨‍👩‍👧‍👦 soon. Rating: 👍🏽 5/5. Proudly made in 🇮🇳 India!';

      const raw = RawSmsMessage(
        id: 'emoji_msg_1',
        threadId: 't_emoji',
        sender: 'BZ-SWIGGY-P',
        body: emojiBody,
        receivedAtMillis: 1756700000000,
        isRead: false,
      );

      final dataSource = FakeSmsDataSource(initialMessages: [raw]);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();
      final stored = await repo.getMessageById('emoji_msg_1');
      expect(stored, isNotNull);
      expect(stored!.body, emojiBody);
      expect(stored.body.contains('🎉'), isTrue);
      expect(stored.body.contains('👨‍👩‍👧‍👦'), isTrue); // ZWJ sequence
      expect(stored.body.contains('👍🏽'), isTrue); // Skin tone modifier
      expect(stored.body.contains('🇮🇳'), isTrue); // Country flag
      expect(stored.category, CategoryType.promotional);

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 9. Hindi (हिन्दी)
    // -------------------------------------------------------------------------
    test('Hindi (हिन्दी) OTP extraction and financial transaction messages', () async {
      final hindiMessages = [
        const RawSmsMessage(
          id: 'hindi_otp_1',
          threadId: 't_hindi',
          sender: 'AD-SBIBNK-T',
          body: 'आपका ओटीपी 482921 है। कृपया इसे किसी के साथ साझा न करें। वैध: 10 मिनट।',
          receivedAtMillis: 1756700000000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'hindi_txn_1',
          threadId: 't_hindi',
          sender: 'AD-SBIBNK-T',
          body: 'आपके बैंक खाते में ₹5,000 जमा किए गए हैं। शेष राशि ₹24,500 है।',
          receivedAtMillis: 1756700010000,
          isRead: true,
        ),
        const RawSmsMessage(
          id: 'hindi_promo_1',
          threadId: 't_hindi',
          sender: 'VM-AMAZON-P',
          body: 'ग्रेट इंडियन फेस्टिवल! 50% की भारी छूट! आज ही खरीदें।',
          receivedAtMillis: 1756700020000,
          isRead: true,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: hindiMessages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();

      final otpMsg = await repo.getMessageById('hindi_otp_1');
      expect(otpMsg, isNotNull);
      expect(otpMsg!.otp, '482921');
      expect(otpMsg.body.contains('साझा न करें'), isTrue);

      final txnMsg = await repo.getMessageById('hindi_txn_1');
      expect(txnMsg, isNotNull);
      expect(txnMsg!.category, CategoryType.transactional);
      expect(txnMsg.body.contains('जमा'), isTrue);

      final promoMsg = await repo.getMessageById('hindi_promo_1');
      expect(promoMsg, isNotNull);
      expect(promoMsg!.category, CategoryType.promotional);

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 10. Marathi (मराठी)
    // -------------------------------------------------------------------------
    test('Marathi (मराठी) OTP extraction and banking messages', () async {
      final marathiMessages = [
        const RawSmsMessage(
          id: 'marathi_otp_1',
          threadId: 't_marathi',
          sender: 'AD-BOIND-T',
          body: 'तुमचा ओटीपी 592814 आहे. कोणाशीही शेअर करू नका. बँक ऑफ इंडिया.',
          receivedAtMillis: 1756700000000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'marathi_txn_1',
          threadId: 't_marathi',
          sender: 'AD-MAHABK-T',
          body: 'तुमच्या बँक खात्यातून ₹1,500 काढले गेले आहेत. उर्वरित शिल्लक ₹12,450 आहे.',
          receivedAtMillis: 1756700010000,
          isRead: true,
        ),
        const RawSmsMessage(
          id: 'marathi_promo_1',
          threadId: 't_marathi',
          sender: 'BZ-DMART-P',
          body: 'दिवाळी विशेष सवलत! सर्व किराणा मालावर २०% पर्यंत सूट. आजच खरेदी करा.',
          receivedAtMillis: 1756700020000,
          isRead: true,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: marathiMessages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();

      final otpMsg = await repo.getMessageById('marathi_otp_1');
      expect(otpMsg, isNotNull);
      expect(otpMsg!.otp, '592814');

      final txnMsg = await repo.getMessageById('marathi_txn_1');
      expect(txnMsg, isNotNull);
      expect(txnMsg!.category, CategoryType.transactional);
      expect(txnMsg.body.contains('काढले गेले'), isTrue);

      final promoMsg = await repo.getMessageById('marathi_promo_1');
      expect(promoMsg, isNotNull);
      expect(promoMsg!.category, CategoryType.promotional);

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 11. Other Indian languages (Tamil, Telugu, Bengali, Gujarati, Kannada, Malayalam, Punjabi)
    // -------------------------------------------------------------------------
    test('Other Indian languages (Tamil, Telugu, Bengali, Gujarati, Kannada, Malayalam, Punjabi)', () async {
      final regionalMessages = [
        const RawSmsMessage(
          id: 'tamil_msg',
          threadId: 't_reg',
          sender: 'AD-SBIBNK-T',
          body: 'உங்கள் OTP 391827. யாருடனும் பகிர வேண்டாம். கணக்கில் ₹2,000 வரவு வைக்கப்பட்டது.',
          receivedAtMillis: 1756700000000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'telugu_msg',
          threadId: 't_reg',
          sender: 'AD-ANDBNK-T',
          body: 'మీ OTP 482915. ఎవరితోనూ పంచుకోవద్దు. మీ ఖాతాలో ₹3,500 జమ చేయబడింది.',
          receivedAtMillis: 1756700010000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'bengali_msg',
          threadId: 't_reg',
          sender: 'AD-UBIBNK-T',
          body: 'আপনার OTP হল 928371. এটি কারও সাথে শেয়ার করবেন না। হিসাবে ₹1,500 জমা হয়েছে।',
          receivedAtMillis: 1756700020000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'gujarati_msg',
          threadId: 't_reg',
          sender: 'AD-BOBBNK-T',
          body: 'તમારો OTP 719284 છે. કોઈની સાથે શેર કરશો નહીં. ખાતામાં ₹2,000 જમા થયા છે.',
          receivedAtMillis: 1756700030000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'kannada_msg',
          threadId: 't_reg',
          sender: 'AD-CANBNK-T',
          body: 'ನಿಮ್ಮ OTP 849201 ಆಗಿದೆ. ಯಾರಿಗೂ ಹಂಚಿಕೊಳ್ಳಬೇಡಿ. ಕೆನರಾ ಬ್ಯಾಂಕ್.',
          receivedAtMillis: 1756700040000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'malayalam_msg',
          threadId: 't_reg',
          sender: 'AD-FEDBNK-T',
          body: 'നിങ്ങളുടെ OTP 638291 ആണ്. ആരുമായും പങ്കിടരുത്. ഫെഡറൽ ബാങ്ക്.',
          receivedAtMillis: 1756700050000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'punjabi_msg',
          threadId: 't_reg',
          sender: 'AD-PNBBNK-T',
          body: 'ਤੁਹਾਡਾ OTP 518294 ਹੈ। ਕਿਸੇ ਨਾਲ ਸਾਂਝਾ ਨਾ ਕਰੋ। ਪੰਜਾਬ ਨੈਸ਼ਨਲ ਬੈਂਕ।',
          receivedAtMillis: 1756700060000,
          isRead: false,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: regionalMessages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();

      // Check Tamil
      final tamil = await repo.getMessageById('tamil_msg');
      expect(tamil, isNotNull);
      expect(tamil!.otp, '391827');
      expect(tamil.category, CategoryType.transactional);

      // Check Telugu
      final telugu = await repo.getMessageById('telugu_msg');
      expect(telugu, isNotNull);
      expect(telugu!.otp, '482915');
      expect(telugu.category, CategoryType.transactional);

      // Check Bengali
      final bengali = await repo.getMessageById('bengali_msg');
      expect(bengali, isNotNull);
      expect(bengali!.otp, '928371');
      expect(bengali.category, CategoryType.transactional);

      // Check Gujarati
      final gujarati = await repo.getMessageById('gujarati_msg');
      expect(gujarati, isNotNull);
      expect(gujarati!.otp, '719284');

      // Check Kannada
      final kannada = await repo.getMessageById('kannada_msg');
      expect(kannada, isNotNull);
      expect(kannada!.otp, '849201');

      // Check Malayalam
      final malayalam = await repo.getMessageById('malayalam_msg');
      expect(malayalam, isNotNull);
      expect(malayalam!.otp, '638291');

      // Check Punjabi
      final punjabi = await repo.getMessageById('punjabi_msg');
      expect(punjabi, isNotNull);
      expect(punjabi!.otp, '518294');

      syncService.dispose();
      dataSource.dispose();
    });

    // -------------------------------------------------------------------------
    // 12. Mixed-language messages
    // -------------------------------------------------------------------------
    test('Mixed-language messages (Hinglish, Marathlish, and multilingual alerts)', () async {
      final mixedMessages = [
        const RawSmsMessage(
          id: 'mixed_hinglish_1',
          threadId: 't_mixed',
          sender: 'AD-SBIBNK-T',
          body: 'Dear customer, aapke SBI account **1234 me ₹2,500 credit hua hai 🎉. '
              'Avail loan offer via Yono app. Check balance at onlinesbi.com',
          receivedAtMillis: 1756700000000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'mixed_marathlish_1',
          threadId: 't_mixed',
          sender: 'AD-HDFCBK-T',
          body: 'तुमच्या a/c **5678 मधून Rs. 350 debit झाले आहेत at Swiggy 🍔. '
              'Available balance is ₹14,200.50. Call 1800-258-3838 if not you.',
          receivedAtMillis: 1756700010000,
          isRead: false,
        ),
        const RawSmsMessage(
          id: 'mixed_delivery_alert',
          threadId: 't_mixed',
          sender: 'VK-DELHIV-S',
          body: 'Delivery Alert: Your package #DEL-8821 is out for delivery today 🚚! '
              'Share delivery code 4912 with executive. धन्यवाद (Thank you)!',
          receivedAtMillis: 1756700020000,
          isRead: false,
        ),
      ];

      final dataSource = FakeSmsDataSource(initialMessages: mixedMessages);
      final syncService = SmsSyncService(
        dataSource: dataSource,
        messageRepo: repo,
        permissionService: permissionService,
        classificationService: classificationService,
      );

      await syncService.syncInitialMessages();

      // Hinglish verification
      final hinglish = await repo.getMessageById('mixed_hinglish_1');
      expect(hinglish, isNotNull);
      expect(hinglish!.category, CategoryType.transactional);
      expect(hinglish.body.contains('credit hua hai'), isTrue);
      expect(hinglish.body.contains('🎉'), isTrue);

      // Marathlish verification
      final marathlish = await repo.getMessageById('mixed_marathlish_1');
      expect(marathlish, isNotNull);
      expect(marathlish!.category, CategoryType.transactional);
      expect(marathlish.body.contains('debit झाले आहेत'), isTrue);
      expect(marathlish.body.contains('🍔'), isTrue);

      // Multilingual delivery alert verification
      final delivery = await repo.getMessageById('mixed_delivery_alert');
      expect(delivery, isNotNull);
      expect(delivery!.category, CategoryType.service);
      expect(delivery.otp, '4912');
      expect(delivery.body.contains('धन्यवाद'), isTrue);
      expect(delivery.body.contains('🚚'), isTrue);

      syncService.dispose();
      dataSource.dispose();
    });
  });
}
