import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/sms_classifier.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SmsClassifier classifier;

  setUp(() {
    classifier = SmsClassifier();
  });

  group('Phase 4 Core Requirement — Suffix-Based Automatic Classification', () {
    test('AX-HDFCBN-P -> Promotional', () async {
      final res = await classifier.classify(
        sender: 'AX-HDFCBN-P',
        body: 'Flat 50% discount on flight bookings. Book now!',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.confidence, 1.0);
      expect(res.confidenceLevel, 'high');
      expect(res.reason, ClassificationReason.officialSuffix);
      expect(res.effectiveReason, 'Explicit -P commercial SMS suffix');
      expect(res.parsedHeader.operatorPrefix, 'AX');
      expect(res.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res.parsedHeader.suffix, 'P');
      expect(res.parsedHeader.rawSender, 'AX-HDFCBN-P');
      expect(res.parsedHeader.normalizedSender, 'AX-HDFCBN-P');
      expect(res.brand, 'HDFC Bank');
      expect(res.brandName, 'HDFC Bank');
    });

    test('AD-HDFCBN-P -> Promotional', () async {
      final res = await classifier.classify(
        sender: 'AD-HDFCBN-P',
        body: 'Special loan offer with lowest interest rates!',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.confidence, 1.0);
      expect(res.reason, ClassificationReason.officialSuffix);
      expect(res.effectiveReason, 'Explicit -P commercial SMS suffix');
      expect(res.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res.parsedHeader.suffix, 'P');
      expect(res.brand, 'HDFC Bank');
    });

    test('AD-HDFCBN-T -> Transactional', () async {
      final res = await classifier.classify(
        sender: 'AD-HDFCBN-T',
        body: 'A/C 1234 debited by INR 1,500.00 on 02-Sep-26. UPI Ref 492019.',
      );
      expect(res.category, CategoryType.transactional);
      expect(res.confidence, 1.0);
      expect(res.reason, ClassificationReason.officialSuffix);
      expect(res.effectiveReason, 'Explicit -T commercial SMS suffix');
      expect(res.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res.parsedHeader.suffix, 'T');
      expect(res.brand, 'HDFC Bank');
    });

    test('AD-HDFCBN-S -> Service', () async {
      final res = await classifier.classify(
        sender: 'AD-HDFCBN-S',
        body: 'Your cheque book request has been processed successfully.',
      );
      expect(res.category, CategoryType.service);
      expect(res.confidence, 1.0);
      expect(res.reason, ClassificationReason.officialSuffix);
      expect(res.effectiveReason, 'Explicit -S commercial SMS suffix');
      expect(res.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res.parsedHeader.suffix, 'S');
      expect(res.brand, 'HDFC Bank');
    });

    test('AD-HDFCBN-G -> Government', () async {
      final res = await classifier.classify(
        sender: 'AD-HDFCBN-G',
        body: 'Government welfare subsidy credit alert.',
      );
      expect(res.category, CategoryType.government);
      expect(res.confidence, 1.0);
      expect(res.reason, ClassificationReason.officialSuffix);
      expect(res.effectiveReason, 'Explicit -G commercial SMS suffix');
      expect(res.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res.parsedHeader.suffix, 'G');
      expect(res.brand, 'HDFC Bank');
    });
  });

  group('Phase 4 Priority 1 Rule — Explicit Suffix Always Wins Over Body Keywords', () {
    test(
      'AX-HDFCBN-P remains Promotional EVEN IF body contains "transaction", "account", "payment"',
      () async {
        final res = await classifier.classify(
          sender: 'AX-HDFCBN-P',
          body:
              'Your account A/C 9876 transaction of payment INR 5,000 earns you 50% discount voucher! Use promo code CASHBACK.',
        );
        expect(res.category, CategoryType.promotional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.effectiveReason, 'Explicit -P commercial SMS suffix');
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'AD-HDFCBN-T remains Transactional EVEN IF body contains "discount", "sale", "offer"',
      () async {
        final res = await classifier.classify(
          sender: 'AD-HDFCBN-T',
          body:
              'Special festive offer discount coupon applied: A/C XX4921 debited for INR 2,499.00.',
        );
        expect(res.category, CategoryType.transactional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.effectiveReason, 'Explicit -T commercial SMS suffix');
      },
    );

    test(
      'AD-HDFCBN-S remains Service EVEN IF body contains financial keywords',
      () async {
        final res = await classifier.classify(
          sender: 'AD-HDFCBN-S',
          body:
              'Service update: your net banking login password has been reset. Balance: INR 45,000.',
        );
        expect(res.category, CategoryType.service);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
      },
    );
  });

  group('Phase 4 Sender Normalization & Formatting Variations', () {
    test('handles lowercase suffix: ax-hdfcbn-p -> Promotional', () async {
      final res = await classifier.classify(
        sender: 'ax-hdfcbn-p',
        body: 'Special clearance sale!',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.confidence, 1.0);
      expect(res.parsedHeader.suffix, 'P');
      expect(res.brand, 'HDFC Bank');
    });

    test('handles whitespace around sender: "  AX-HDFCBN-P  " -> Promotional', () async {
      final res = await classifier.classify(
        sender: '  AX-HDFCBN-P  ',
        body: 'Weekend exclusive flash deals.',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.confidence, 1.0);
      expect(res.parsedHeader.suffix, 'P');
      expect(res.brand, 'HDFC Bank');
    });

    test('handles spaces around hyphens: "AX - HDFCBN - P" -> Promotional', () async {
      final res = await classifier.classify(
        sender: 'AX - HDFCBN - P',
        body: 'Special offers for you.',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res.parsedHeader.suffix, 'P');
      expect(res.brand, 'HDFC Bank');
    });

    test('handles underscore delimiter: "AX_HDFCBN_P" -> Promotional', () async {
      final res = await classifier.classify(
        sender: 'AX_HDFCBN_P',
        body: 'Exclusive discounts.',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res.parsedHeader.suffix, 'P');
      expect(res.brand, 'HDFC Bank');
    });

    test('handles carrier prepend: "+91AX-HDFCBN-P" and "+91-AD-HDFCBN-T"', () async {
      final res1 = await classifier.classify(
        sender: '+91AX-HDFCBN-P',
        body: 'Get 20% off today.',
      );
      expect(res1.category, CategoryType.promotional);
      expect(res1.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res1.parsedHeader.suffix, 'P');

      final res2 = await classifier.classify(
        sender: '+91-AD-HDFCBN-T',
        body: 'A/C credited with salary.',
      );
      expect(res2.category, CategoryType.transactional);
      expect(res2.parsedHeader.cleanHeader, 'HDFCBN');
      expect(res2.parsedHeader.suffix, 'T');
    });
  });

  group('Phase 4 Fallbacks, Personal Numbers, and Malformed Senders', () {
    test('unknown sender with ambiguous content -> Other', () async {
      final res = await classifier.classify(
        sender: 'UNKNOWN-ENTITY',
        body: 'Hello, please review the document when you have time.',
      );
      expect(res.category, CategoryType.other);
      expect(res.confidence, 0.0);
      expect(res.reason, ClassificationReason.unknown);
    });

    test('personal phone number -> Other unless confidently classified otherwise', () async {
      final res = await classifier.classify(
        sender: '+919876543210',
        body: 'Hey bro, are we meeting at 7 PM for dinner?',
      );
      expect(res.category, CategoryType.other);
      expect(res.confidence, 0.0);
      expect(res.reason, ClassificationReason.unknown);
      expect(res.parsedHeader.isCommercial, isFalse);
    });

    test('10-digit mobile number -> Other', () async {
      final res = await classifier.classify(
        sender: '9876543210',
        body: 'Can you call me back?',
      );
      expect(res.category, CategoryType.other);
      expect(res.confidence, 0.0);
      expect(res.parsedHeader.isCommercial, isFalse);
    });

    test('malformed isolated suffix -> Other', () async {
      final res = await classifier.classify(
        sender: '-P',
        body: 'Random text message.',
      );
      expect(res.category, CategoryType.other);
      expect(res.parsedHeader.isCommercial, isFalse);
    });

    test('empty sender -> Other', () async {
      final res = await classifier.classify(
        sender: '',
        body: 'Empty sender test.',
      );
      expect(res.category, CategoryType.other);
      expect(res.parsedHeader.isCommercial, isFalse);
    });
  });
}
