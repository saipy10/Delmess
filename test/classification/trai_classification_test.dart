import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/classification_engine.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 7.16 Suite A — TRAI Classification Tests', () {
    late ClassificationEngine engine;

    setUp(() {
      engine = ClassificationEngine();
    });

    test('-T suffix classifies as Transactional with TRAI_SUFFIX source', () async {
      final result = await engine.classify(
        sender: 'AD-HDFCBK-T',
        body: '₹5,000 debited from your account.',
      );

      expect(result.category, CategoryType.transactional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'T');
      expect(result.parsedHeader.rawSender, 'AD-HDFCBK-T');
      expect(result.parsedHeader.cleanHeader, 'HDFCBK');
      expect(result.parsedHeader.operatorPrefix, 'AD');
    });

    test('-S suffix classifies as Service with TRAI_SUFFIX source', () async {
      final result = await engine.classify(
        sender: 'AD-SWIGGY-S',
        body: 'Your food order is on the way.',
      );

      expect(result.category, CategoryType.service);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'S');
      expect(result.parsedHeader.rawSender, 'AD-SWIGGY-S');
      expect(result.parsedHeader.cleanHeader, 'SWIGGY');
    });

    test('-P suffix classifies as Promotional with TRAI_SUFFIX source', () async {
      final result = await engine.classify(
        sender: 'VM-AMAZON-P',
        body: 'Great Indian Festival discounts live now!',
      );

      expect(result.category, CategoryType.promotional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'P');
      expect(result.parsedHeader.cleanHeader, 'AMAZON');
    });

    test('-G suffix classifies as Government with TRAI_SUFFIX source', () async {
      final result = await engine.classify(
        sender: 'XX-GOVT-G',
        body: 'National voter awareness bulletin.',
      );

      expect(result.category, CategoryType.government);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'G');
      expect(result.parsedHeader.cleanHeader, 'GOVT');
    });

    test('TRAI suffix is authoritative over keywords: -P remains Promotional with financial keywords', () async {
      final result = await engine.classify(
        sender: 'AD-HDFCBK-P',
        body: 'Get 5% cashback on your next UPI payment.',
      );

      expect(result.category, CategoryType.promotional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'P');
    });

    test('TRAI suffix is authoritative: -S remains Service even with OTP', () async {
      final result = await engine.classify(
        sender: 'AD-HDFCBK-S',
        body: 'Your OTP is 482913.',
      );

      expect(result.category, CategoryType.service);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'S');
    });

    test('handles lowercase suffix: ax-hdfcbn-p -> Promotional', () async {
      final result = await engine.classify(
        sender: 'ax-hdfcbn-p',
        body: '50% off loan processing fees',
      );

      expect(result.category, CategoryType.promotional);
      expect(result.traiSuffix, 'P');
      expect(result.parsedHeader.rawSender, 'ax-hdfcbn-p');
    });

    test('handles whitespace around sender: "  AX-HDFCBN-T  " -> Transactional', () async {
      final result = await engine.classify(
        sender: '  AX-HDFCBN-T  ',
        body: 'Statement generated',
      );

      expect(result.category, CategoryType.transactional);
      expect(result.traiSuffix, 'T');
      expect(result.parsedHeader.cleanHeader, 'HDFCBN');
    });

    test('unknown suffix (AD-HDFCBK-X) falls back gracefully', () async {
      final result = await engine.classify(
        sender: 'AD-HDFCBK-X',
        body: 'General announcement',
      );

      expect(result.traiSuffix, isNull);
    });

    test('missing suffix falls back to known header or content pattern or other', () async {
      final result = await engine.classify(
        sender: '9876543210',
        body: 'Hello what are you doing?',
      );

      expect(result.category, CategoryType.other);
      expect(result.categorySource, CategorySource.fallback);
      expect(result.traiSuffix, isNull);
    });
  });
}
