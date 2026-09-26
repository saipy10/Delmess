import 'package:delmess/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Schema v4 & Migration Tests', () {
    final now = DateTime(2026, 9, 2, 12, 0, 0);

    test('verifies schemaVersion is 4', () {
      expect(db.schemaVersion, 4);
    });

    test('inserts and retrieves all Phase 4 intelligence columns including rawSender, normalizedSender, brandName', () async {
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion(
              id: const Value('msg_test_v3'),
              threadId: const Value('thread_test_v3'),
              sender: const Value('AX-HDFCBN-P'),
              rawSender: const Value('AX-HDFCBN-P'),
              normalizedSender: const Value('AX-HDFCBN-P'),
              header: const Value('HDFCBN'),
              brand: const Value('HDFC Bank'),
              brandName: const Value('HDFC Bank'),
              body: const Value('Special loan discount offer!'),
              receivedAt: Value(now),
              category: const Value('promotional'),
              classificationConfidence: const Value(1.0),
              classificationReason: const Value('Explicit -P commercial SMS suffix'),
              operatorPrefix: const Value('AX'),
              parsedHeader: const Value('HDFCBN'),
              messageTypeSuffix: const Value('P'),
              classificationVersion: const Value(2),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final row = await (db.select(
        db.messages,
      )..where((tbl) => tbl.id.equals('msg_test_v3'))).getSingle();

      expect(row.id, 'msg_test_v3');
      expect(row.sender, 'AX-HDFCBN-P');
      expect(row.rawSender, 'AX-HDFCBN-P');
      expect(row.normalizedSender, 'AX-HDFCBN-P');
      expect(row.header, 'HDFCBN');
      expect(row.brand, 'HDFC Bank');
      expect(row.brandName, 'HDFC Bank');
      expect(row.category, 'promotional');
      expect(row.operatorPrefix, 'AX');
      expect(row.parsedHeader, 'HDFCBN');
      expect(row.messageTypeSuffix, 'P');
      expect(row.classificationVersion, 2);
      expect(row.classificationConfidence, 1.0);
      expect(row.classificationReason, 'Explicit -P commercial SMS suffix');
    });

    test('inserts and retrieves all Phase 7 three-signal intelligence columns', () async {
      await db
          .into(db.messages)
          .insert(
            MessagesCompanion(
              id: const Value('msg_test_v4'),
              threadId: const Value('thread_test_v4'),
              sender: const Value('AD-HDFCBK-T'),
              rawSender: const Value('AD-HDFCBK-T'),
              normalizedSender: const Value('AD-HDFCBK-T'),
              header: const Value('HDFCBK'),
              brand: const Value('HDFC Bank'),
              brandName: const Value('HDFC Bank'),
              body: const Value('₹5,000 debited from A/c XX1234 via UPI.'),
              receivedAt: Value(now),
              category: const Value('transactional'),
              categorySource: const Value('TRAI_SUFFIX'),
              traiSuffix: const Value('T'),
              isPayment: const Value(true),
              paymentType: const Value('UPI'),
              paymentDirection: const Value('DEBIT'),
              paymentSource: const Value('PAYMENT_PATTERN'),
              hasOtp: const Value(false),
              otpValue: const Value(null),
              otpSource: const Value('NONE'),
              classificationConfidence: const Value(1.0),
              classificationReason: const Value('Explicit -T commercial SMS suffix'),
              operatorPrefix: const Value('AD'),
              parsedHeader: const Value('HDFCBK'),
              messageTypeSuffix: const Value('T'),
              classificationVersion: const Value(3),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final row = await (db.select(
        db.messages,
      )..where((tbl) => tbl.id.equals('msg_test_v4'))).getSingle();

      expect(row.id, 'msg_test_v4');
      expect(row.category, 'transactional');
      expect(row.categorySource, 'TRAI_SUFFIX');
      expect(row.traiSuffix, 'T');
      expect(row.isPayment, true);
      expect(row.paymentType, 'UPI');
      expect(row.paymentDirection, 'DEBIT');
      expect(row.paymentSource, 'PAYMENT_PATTERN');
      expect(row.hasOtp, false);
      expect(row.otpValue, isNull);
      expect(row.otpSource, 'NONE');
      expect(row.brand, 'HDFC Bank');
      expect(row.classificationVersion, 3);
    });

    test(
      'supports nullable values for non-commercial or unparsed senders',
      () async {
        await db
            .into(db.messages)
            .insert(
              MessagesCompanion(
                id: const Value('msg_personal'),
                threadId: const Value('thread_personal'),
                sender: const Value('+919876543210'),
                header: const Value('+919876543210'),
                body: const Value('Hello friend'),
                receivedAt: Value(now),
                category: const Value('other'),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        final row = await (db.select(
          db.messages,
        )..where((tbl) => tbl.id.equals('msg_personal'))).getSingle();

        expect(row.id, 'msg_personal');
        expect(row.operatorPrefix, isNull);
        expect(row.parsedHeader, isNull);
        expect(row.messageTypeSuffix, isNull);
        expect(row.traiSuffix, isNull);
        expect(row.isPayment, false);
        expect(row.paymentType, 'NONE');
        expect(row.hasOtp, false);
        expect(row.brand, isNull);
        expect(row.otp, isNull);
        expect(row.classificationVersion, 1); // default value
      },
    );
  });
}
