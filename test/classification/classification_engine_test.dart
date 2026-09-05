import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/classification_engine.dart';
import 'package:delmess/features/classification/domain/known_header_classifier.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sender_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ClassificationEngine engine;
  late KnownHeaderClassifier knownClassifier;

  setUp(() {
    knownClassifier = KnownHeaderClassifier();
    final now = DateTime.now();

    // Preload known headers in cache for synchronous / unit test execution
    knownClassifier.cacheMetadata(
      SenderMetadata(
        id: '1',
        header: 'HDFCBK',
        brand: 'HDFC Bank',
        organization: 'HDFC Bank Ltd.',
        industry: 'Banking & Financial Services',
        updatedAt: now,
      ),
    );
    knownClassifier.cacheMetadata(
      SenderMetadata(
        id: '2',
        header: 'AMAZON',
        brand: 'Amazon India',
        organization: 'Amazon',
        industry: 'E-Commerce',
        updatedAt: now,
      ),
    );
    knownClassifier.cacheMetadata(
      SenderMetadata(
        id: '3',
        header: 'SWIGGY',
        brand: 'Swiggy',
        organization: 'Bundl',
        industry: 'Food & Delivery',
        updatedAt: now,
      ),
    );
    knownClassifier.cacheMetadata(
      SenderMetadata(
        id: '4',
        header: 'GOVTIN',
        brand: 'Govt of India',
        organization: 'National Informatics Centre',
        industry: 'Government Services',
        updatedAt: now,
      ),
    );

    engine = ClassificationEngine(knownHeaderClassifier: knownClassifier);
  });

  group('Official TRAI Suffix Classification Tests', () {
    test(
      'AX-HDFCBN-P classifies as Promotional with officialSuffix reason and resolves HDFC Bank',
      () async {
        final res = await engine.classify(
          sender: 'AX-HDFCBN-P',
          body: 'Special loan offer with 50% discount on processing fee!',
        );
        expect(res.category, CategoryType.promotional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'AD-HDFCBN-P classifies as Promotional with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'AD-HDFCBN-P',
          body: 'Great savings festival deals!',
        );
        expect(res.category, CategoryType.promotional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'AD-HDFCBN-T classifies as Transactional with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'AD-HDFCBN-T',
          body: 'Your A/C ending in 4321 is credited with INR 10,000.',
        );
        expect(res.category, CategoryType.transactional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'AD-HDFCBN-S classifies as Service with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'AD-HDFCBN-S',
          body: 'Your cheque book request has been dispatched.',
        );
        expect(res.category, CategoryType.service);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'AD-HDFCBN-G classifies as Government with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'AD-HDFCBN-G',
          body: 'Official Government Treasury alert regarding scheme disbursement.',
        );
        expect(res.category, CategoryType.government);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test('handles lowercase suffix: ax-hdfcbn-p -> Promotional', () async {
      final res = await engine.classify(
        sender: 'ax-hdfcbn-p',
        body: 'Flat 50% discount on credit card purchases.',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.confidence, 1.0);
      expect(res.reason, ClassificationReason.officialSuffix);
      expect(res.brand, 'HDFC Bank');
    });

    test('handles whitespace around sender: "  AX-HDFCBN-P  " -> Promotional', () async {
      final res = await engine.classify(
        sender: '  AX-HDFCBN-P  ',
        body: 'Special festive voucher.',
      );
      expect(res.category, CategoryType.promotional);
      expect(res.confidence, 1.0);
      expect(res.reason, ClassificationReason.officialSuffix);
      expect(res.brand, 'HDFC Bank');
    });

    test(
      'AD-HDFCBK-T classifies as Transactional with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'AD-HDFCBK-T',
          body: 'Your account has been debited with INR 2,000.',
        );
        expect(res.category, CategoryType.transactional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'VM-AMAZON-P classifies as Promotional with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'VM-AMAZON-P',
          body: 'Special discounts on electronics today only!',
        );
        expect(res.category, CategoryType.promotional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'Amazon India');
      },
    );

    test(
      'JD-SWIGGY-S classifies as Service with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'JD-SWIGGY-S',
          body: 'Your food order is on the way.',
        );
        expect(res.category, CategoryType.service);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'Swiggy');
      },
    );

    test(
      'XX-GOVT-G classifies as Government with officialSuffix reason',
      () async {
        final res = await engine.classify(
          sender: 'XX-GOVT-G',
          body: 'Advisory alert from Ministry of Health.',
        );
        expect(res.category, CategoryType.government);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
      },
    );
  });

  group('Principle: Official Suffix Overrides Content Keywords', () {
    test(
      'AX-HDFCBN-P remains Promotional EVEN IF body contains financial/transaction keywords',
      () async {
        final res = await engine.classify(
          sender: 'AX-HDFCBN-P',
          body:
              'Your account A/C ending 1234 has a special pre-approved transaction loan of INR 50,000. Payment due date discounts apply!',
        );
        expect(res.category, CategoryType.promotional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'AD-HDFCBK-T remains Transactional even with heavy promotional keywords',
      () async {
        final res = await engine.classify(
          sender: 'AD-HDFCBK-T',
          body: 'Get 90% off sale discount with our special coupon code!',
        );
        expect(res.category, CategoryType.transactional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
      },
    );

    test(
      'VM-AMAZON-P remains Promotional even with transactional keywords',
      () async {
        final res = await engine.classify(
          sender: 'VM-AMAZON-P',
          body: 'INR 1000 debited for voucher purchase via UPI.',
        );
        expect(res.category, CategoryType.promotional);
        expect(res.confidence, 1.0);
        expect(res.reason, ClassificationReason.officialSuffix);
      },
    );
  });

  group('Known Header Metadata Classification Tests', () {
    test(
      'HDFCBK without suffix infers Transactional category from metadata',
      () async {
        final res = await engine.classify(
          sender: 'AD-HDFCBK',
          body: 'Welcome to your banking portal.',
        );
        expect(res.category, CategoryType.transactional);
        expect(res.confidence, 0.90);
        expect(res.reason, ClassificationReason.knownHeader);
        expect(res.brand, 'HDFC Bank');
      },
    );

    test(
      'GOVTIN without suffix infers Government category from metadata',
      () async {
        final res = await engine.classify(
          sender: 'GOVTIN',
          body: 'Public notification regarding filing.',
        );
        expect(res.category, CategoryType.government);
        expect(res.confidence, 0.90);
        expect(res.reason, ClassificationReason.knownHeader);
        expect(res.brand, 'Govt of India');
      },
    );

    test(
      'SWIGGY without suffix infers Service category from metadata',
      () async {
        final res = await engine.classify(
          sender: 'SWIGGY',
          body: 'Thanks for using our app.',
        );
        expect(res.category, CategoryType.service);
        expect(res.confidence, 0.90);
        expect(res.reason, ClassificationReason.knownHeader);
        expect(res.brand, 'Swiggy');
      },
    );
  });

  group('Conservative Content Fallback Tests', () {
    test(
      'classifies financial message with no suffix/metadata as Transactional',
      () async {
        final res = await engine.classify(
          sender: 'UNKNOWN-BANK',
          body: 'Your A/C ending with 4567 debited by INR 350.00 via UPI.',
        );
        expect(res.category, CategoryType.transactional);
        expect(res.confidence, 0.80);
        expect(res.reason, ClassificationReason.contentRule);
      },
    );

    test(
      'classifies delivery message with no suffix/metadata as Service',
      () async {
        final res = await engine.classify(
          sender: 'COURIER-X',
          body: 'Your shipment order id 98213 is out for delivery today.',
        );
        expect(res.category, CategoryType.service);
        expect(res.confidence, 0.75);
        expect(res.reason, ClassificationReason.contentRule);
      },
    );

    test(
      'classifies discount message with no suffix/metadata as Promotional',
      () async {
        final res = await engine.classify(
          sender: 'SHOP-ALERT',
          body: 'Flat 40% off on all shoes! Shop now before midnight.',
        );
        expect(res.category, CategoryType.promotional);
        expect(res.confidence, 0.75);
        expect(res.reason, ClassificationReason.contentRule);
      },
    );

    test(
      'classifies Aadhaar/Govt message with no suffix/metadata as Government',
      () async {
        final res = await engine.classify(
          sender: 'AUTH-PORTAL',
          body: 'Your Aadhaar card download request has been processed.',
        );
        expect(res.category, CategoryType.government);
        expect(res.confidence, 0.85);
        expect(res.reason, ClassificationReason.contentRule);
      },
    );
  });

  group('Unknown / Personal Message Tests', () {
    test('classifies personal phone number as Other', () async {
      final res = await engine.classify(
        sender: '+919876543210',
        body: 'Hey, are you free this evening for coffee?',
      );
      expect(res.category, CategoryType.other);
      expect(res.confidence, 0.0);
      expect(res.reason, ClassificationReason.unknown);
      expect(res.brand, isNull);
    });

    test('classifies ambiguous message without indicators as Other', () async {
      final res = await engine.classify(
        sender: 'RANDOM',
        body: 'Hello there, please check your email when possible.',
      );
      expect(res.category, CategoryType.other);
      expect(res.confidence, 0.0);
      expect(res.reason, ClassificationReason.unknown);
    });
  });
}
