import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/classification/domain/classification_engine.dart';
import 'package:delmess/features/classification/domain/message_classification_service.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sender_metadata.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftMessageRepository messageRepo;
  late DriftSenderMetadataRepository senderRepo;
  late ClassificationEngine engine;
  late MessageClassificationService classificationService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    messageRepo = DriftMessageRepository(db);
    senderRepo = DriftSenderMetadataRepository(db);
    engine = ClassificationEngine(metadataRepository: senderRepo);
    classificationService = MessageClassificationService(
      engine: engine,
      repository: messageRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Reclassification Tests', () {
    test(
      'reclassifies an existing message after sender metadata is added',
      () async {
        final now = DateTime.now();

        // 1. Insert unclassified message with unknown header
        final initialMessage = SmsMessage(
          id: 'msg_reclass_1',
          threadId: 'thread_reclass_1',
          sender: 'AD-PAYCORP',
          header: 'AD-PAYCORP',
          body: 'Welcome to our service. Please verify your profile.',
          receivedAt: now,
          category: CategoryType.other,
          classificationConfidence: 0.0,
          classificationReason: ClassificationReason.unknown,
          createdAt: now,
          updatedAt: now,
        );
        await messageRepo.insertMessage(initialMessage);

        // Verify initial state
        final savedBefore = await messageRepo.getMessageById('msg_reclass_1');
        expect(savedBefore?.category, CategoryType.other);
        expect(savedBefore?.brand, isNull);

        // 2. Add sender metadata for PAYCORP as a banking institution
        await senderRepo.upsertMetadata(
          SenderMetadata(
            id: 'meta_paycorp',
            header: 'PAYCORP',
            brand: 'PayCorp Banking',
            organization: 'PayCorp Global Ltd.',
            industry: 'Banking & Financial Services',
            updatedAt: now,
          ),
        );

        // Clear cache so new metadata is fetched
        engine.knownHeaderClassifier.clearCache();

        // 3. Reclassify message
        final reclassified = await classificationService.reclassifyMessage(
          'msg_reclass_1',
        );

        expect(reclassified, isNotNull);
        expect(reclassified!.brand, 'PayCorp Banking');
        expect(reclassified.category, CategoryType.transactional);
        expect(
          reclassified.classificationReason,
          ClassificationReason.knownHeader,
        );
        expect(reclassified.classificationConfidence, 0.90);
        expect(reclassified.parsedHeader, 'PAYCORP');
        expect(reclassified.operatorPrefix, 'AD');

        // 4. Verify persisted state in database
        final savedAfter = await messageRepo.getMessageById('msg_reclass_1');
        expect(savedAfter?.category, CategoryType.transactional);
        expect(savedAfter?.brand, 'PayCorp Banking');
        expect(savedAfter?.parsedHeader, 'PAYCORP');
        expect(savedAfter?.operatorPrefix, 'AD');
      },
    );

    test(
      'reclassifyAllMessages executes in batches and reports progress',
      () async {
        final now = DateTime.now();

        // Seed 5 messages with suffixes
        final msgs = [
          SmsMessage(
            id: 'msg_b1',
            threadId: 't1',
            sender: 'AD-HDFCBK-T',
            header: 'AD-HDFCBK-T',
            body: 'Salary credited Rs 50,000.',
            receivedAt: now,
            category: CategoryType.other, // deliberately unclassified
            createdAt: now,
            updatedAt: now,
          ),
          SmsMessage(
            id: 'msg_b2',
            threadId: 't2',
            sender: 'VM-AMAZON-P',
            header: 'VM-AMAZON-P',
            body: 'Great summer discounts!',
            receivedAt: now.add(const Duration(minutes: 1)),
            category: CategoryType.other,
            createdAt: now,
            updatedAt: now,
          ),
          SmsMessage(
            id: 'msg_b3',
            threadId: 't3',
            sender: 'JD-SWIGGY-S',
            header: 'JD-SWIGGY-S',
            body: 'Your meal is arriving in 10 mins.',
            receivedAt: now.add(const Duration(minutes: 2)),
            category: CategoryType.other,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        await messageRepo.insertMessages(msgs);

        int progressReports = 0;
        final count = await classificationService.reclassifyAllMessages(
          batchSize: 2,
          onProgress: (processed, total) {
            progressReports++;
            expect(total, 3);
            expect(processed, greaterThan(0));
          },
        );

        expect(count, 3);
        expect(progressReports, greaterThanOrEqualTo(2));

        // Verify all were updated to correct categories
        final m1 = await messageRepo.getMessageById('msg_b1');
        expect(m1?.category, CategoryType.transactional);
        expect(m1?.classificationReason, ClassificationReason.officialSuffix);
        expect(m1?.messageTypeSuffix, 'T');

        final m2 = await messageRepo.getMessageById('msg_b2');
        expect(m2?.category, CategoryType.promotional);
        expect(m2?.messageTypeSuffix, 'P');

        final m3 = await messageRepo.getMessageById('msg_b3');
        expect(m3?.category, CategoryType.service);
        expect(m3?.messageTypeSuffix, 'S');
      },
    );

    test(
      'reclassifies AX-HDFCBN-P from Other to Promotional and preserves stars, pins, and labels',
      () async {
        final now = DateTime.now();

        // 1. Existing message in Other
        final initialMsg = SmsMessage(
          id: 'msg_hdfcbn_promo',
          threadId: 'thread_hdfcbn',
          sender: 'AX-HDFCBN-P',
          header: 'AX-HDFCBN-P',
          body:
              'A/C XX1234 pre-approved loan of INR 2,00,000 at 0% processing fee. Limited period offer!',
          receivedAt: now,
          category: CategoryType.other, // Currently appears under Other
          classificationConfidence: 0.0,
          classificationReason: ClassificationReason.unknown,
          isStarred: true,
          isPinned: true,
          isRead: false,
          classificationVersion: 1, // Older version
          createdAt: now,
          updatedAt: now,
        );
        await messageRepo.insertMessage(initialMsg);

        final totalBefore = await messageRepo.getMessageCount();
        expect(totalBefore, 1);

        // 2. Run reclassifyIfNeeded
        final reclassifiedCount = await classificationService.reclassifyIfNeeded();
        expect(reclassifiedCount, 1);

        // 3. Verify no duplicate messages were created
        final totalAfter = await messageRepo.getMessageCount();
        expect(totalAfter, 1);

        // 4. Verify updated fields
        final updated = await messageRepo.getMessageById('msg_hdfcbn_promo');
        expect(updated, isNotNull);
        expect(updated!.category, CategoryType.promotional);
        expect(updated.rawSender, 'AX-HDFCBN-P');
        expect(updated.header, 'HDFCBN');
        expect(updated.brand, 'HDFC Bank');
        expect(updated.operatorPrefix, 'AX');
        expect(updated.messageTypeSuffix, 'P');
        expect(updated.classificationConfidence, 1.0);
        expect(updated.classificationReason, ClassificationReason.officialSuffix);
        expect(updated.effectiveReasonDescription, contains('-P'));

        // 5. Verify user state (starred, pinned, unread) is preserved
        expect(updated.isStarred, isTrue);
        expect(updated.isPinned, isTrue);
        expect(updated.isRead, isFalse);
      },
    );
  });
}
