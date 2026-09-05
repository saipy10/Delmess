import 'package:delmess/features/classification/domain/known_header_classifier.dart';
import 'package:delmess/features/messages/domain/sender_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late KnownHeaderClassifier classifier;

  setUp(() {
    classifier = KnownHeaderClassifier();
    final now = DateTime.now();

    classifier.cacheMetadata(
      SenderMetadata(
        id: '1',
        header: 'HDFCBK',
        brand: 'HDFC Bank',
        organization: 'HDFC Bank Ltd.',
        industry: 'Banking',
        updatedAt: now,
      ),
    );
    classifier.cacheMetadata(
      SenderMetadata(
        id: '2',
        header: 'AMAZON',
        brand: 'Amazon India',
        organization: 'Amazon',
        industry: 'E-Commerce',
        updatedAt: now,
      ),
    );
    classifier.cacheMetadata(
      SenderMetadata(
        id: '3',
        header: 'SWIGGY',
        brand: 'Swiggy',
        organization: 'Bundl',
        industry: 'Food & Delivery',
        updatedAt: now,
      ),
    );
  });

  group('Brand Resolution Tests', () {
    test('resolves known header HDFCBK to HDFC Bank', () async {
      final meta = await classifier.lookupMetadata('HDFCBK');
      expect(meta, isNotNull);
      expect(meta!.brand, 'HDFC Bank');
    });

    test('resolves known header case-insensitively', () async {
      final meta = await classifier.lookupMetadata('amazon');
      expect(meta, isNotNull);
      expect(meta!.brand, 'Amazon India');
    });

    test('resolves known header SWIGGY to Swiggy', () async {
      final meta = await classifier.lookupMetadata('SWIGGY');
      expect(meta, isNotNull);
      expect(meta!.brand, 'Swiggy');
    });

    test(
      'unknown header UNKNOWN123 returns null and never invents brand name',
      () async {
        final meta = await classifier.lookupMetadata('UNKNOWN123');
        expect(meta, isNull);
      },
    );
  });
}
