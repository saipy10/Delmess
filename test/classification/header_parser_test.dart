import 'package:delmess/features/classification/domain/header_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HeaderParser parser;

  setUp(() {
    parser = const HeaderParser();
  });

  group('HeaderParser Commercial Suffix Tests', () {
    test('parses promotional commercial header: AX-HDFCBN-P', () {
      final res = parser.parse('AX-HDFCBN-P');
      expect(res.rawSender, 'AX-HDFCBN-P');
      expect(res.operatorPrefix, 'AX');
      expect(res.cleanHeader, 'HDFCBN');
      expect(res.suffix, 'P');
      expect(res.isCommercial, isTrue);
    });

    test('parses promotional commercial header: AD-HDFCBN-P', () {
      final res = parser.parse('AD-HDFCBN-P');
      expect(res.rawSender, 'AD-HDFCBN-P');
      expect(res.operatorPrefix, 'AD');
      expect(res.cleanHeader, 'HDFCBN');
      expect(res.suffix, 'P');
      expect(res.isCommercial, isTrue);
    });

    test('parses transactional commercial header: AD-HDFCBN-T', () {
      final res = parser.parse('AD-HDFCBN-T');
      expect(res.rawSender, 'AD-HDFCBN-T');
      expect(res.operatorPrefix, 'AD');
      expect(res.cleanHeader, 'HDFCBN');
      expect(res.suffix, 'T');
      expect(res.isCommercial, isTrue);
    });

    test('parses service commercial header: AD-HDFCBN-S', () {
      final res = parser.parse('AD-HDFCBN-S');
      expect(res.rawSender, 'AD-HDFCBN-S');
      expect(res.operatorPrefix, 'AD');
      expect(res.cleanHeader, 'HDFCBN');
      expect(res.suffix, 'S');
      expect(res.isCommercial, isTrue);
    });

    test('parses government commercial header: AD-HDFCBN-G', () {
      final res = parser.parse('AD-HDFCBN-G');
      expect(res.rawSender, 'AD-HDFCBN-G');
      expect(res.operatorPrefix, 'AD');
      expect(res.cleanHeader, 'HDFCBN');
      expect(res.suffix, 'G');
      expect(res.isCommercial, isTrue);
    });

    test('parses standard 3-part commercial header: AD-HDFCBK-T', () {
      final res = parser.parse('AD-HDFCBK-T');
      expect(res.rawSender, 'AD-HDFCBK-T');
      expect(res.operatorPrefix, 'AD');
      expect(res.cleanHeader, 'HDFCBK');
      expect(res.suffix, 'T');
      expect(res.isCommercial, isTrue);
    });

    test('parses promotional commercial header: VM-AMAZON-P', () {
      final res = parser.parse('VM-AMAZON-P');
      expect(res.rawSender, 'VM-AMAZON-P');
      expect(res.operatorPrefix, 'VM');
      expect(res.cleanHeader, 'AMAZON');
      expect(res.suffix, 'P');
      expect(res.isCommercial, isTrue);
    });

    test('parses service commercial header: JD-SWIGGY-S', () {
      final res = parser.parse('JD-SWIGGY-S');
      expect(res.rawSender, 'JD-SWIGGY-S');
      expect(res.operatorPrefix, 'JD');
      expect(res.cleanHeader, 'SWIGGY');
      expect(res.suffix, 'S');
      expect(res.isCommercial, isTrue);
    });

    test('parses government commercial header: XX-GOVT-G', () {
      final res = parser.parse('XX-GOVT-G');
      expect(res.rawSender, 'XX-GOVT-G');
      expect(res.operatorPrefix, 'XX');
      expect(res.cleanHeader, 'GOVT');
      expect(res.suffix, 'G');
      expect(res.isCommercial, isTrue);
    });

    test('parses carrier prepended formats: +91AX-HDFCBN-P and +91-AD-HDFCBN-T', () {
      final res1 = parser.parse('+91AX-HDFCBN-P');
      expect(res1.cleanHeader, 'HDFCBN');
      expect(res1.suffix, 'P');
      expect(res1.isCommercial, isTrue);

      final res2 = parser.parse('+91-AD-HDFCBN-T');
      expect(res2.cleanHeader, 'HDFCBN');
      expect(res2.suffix, 'T');
      expect(res2.isCommercial, isTrue);
    });

    test('parses alternate delimiters: AX_HDFCBN_P and AX - HDFCBN - P', () {
      final res1 = parser.parse('AX_HDFCBN_P');
      expect(res1.cleanHeader, 'HDFCBN');
      expect(res1.suffix, 'P');
      expect(res1.isCommercial, isTrue);

      final res2 = parser.parse('AX - HDFCBN - P');
      expect(res2.cleanHeader, 'HDFCBN');
      expect(res2.suffix, 'P');
      expect(res2.isCommercial, isTrue);
    });
  });

  group('HeaderParser Normalization & Preservation Tests', () {
    test('handles lowercase input and preserves rawSender: ad-hdfcbk-t', () {
      const raw = 'ad-hdfcbk-t';
      final res = parser.parse(raw);
      expect(res.rawSender, raw);
      expect(res.operatorPrefix, 'AD');
      expect(res.cleanHeader, 'HDFCBK');
      expect(res.suffix, 'T');
      expect(res.isCommercial, isTrue);
    });

    test(
      'handles leading and trailing whitespace while preserving rawSender',
      () {
        const raw = '  AD-HDFCBK-T  ';
        final res = parser.parse(raw);
        expect(res.rawSender, raw);
        expect(res.operatorPrefix, 'AD');
        expect(res.cleanHeader, 'HDFCBK');
        expect(res.suffix, 'T');
      },
    );
  });

  group('HeaderParser Alternate Formats Tests', () {
    test('parses header without suffix: AD-HDFCBK', () {
      final res = parser.parse('AD-HDFCBK');
      expect(res.rawSender, 'AD-HDFCBK');
      expect(res.operatorPrefix, 'AD');
      expect(res.cleanHeader, 'HDFCBK');
      expect(res.suffix, isNull);
      expect(res.isCommercial, isTrue);
    });

    test(
      'parses bare alphanumeric header without prefix or suffix: AMAZON',
      () {
        final res = parser.parse('AMAZON');
        expect(res.rawSender, 'AMAZON');
        expect(res.operatorPrefix, isNull);
        expect(res.cleanHeader, 'AMAZON');
        expect(res.suffix, isNull);
        expect(res.isCommercial, isTrue);
      },
    );

    test('parses header without operator prefix: HDFCBK-T', () {
      final res = parser.parse('HDFCBK-T');
      expect(res.rawSender, 'HDFCBK-T');
      expect(res.operatorPrefix, isNull);
      expect(res.cleanHeader, 'HDFCBK');
      expect(res.suffix, 'T');
      expect(res.isCommercial, isTrue);
    });
  });

  group('HeaderParser Malformed & Phone Number Tests', () {
    test('rejects unrecognized suffix without crashing: AD-HDFCBK-X', () {
      final res = parser.parse('AD-HDFCBK-X');
      expect(res.rawSender, 'AD-HDFCBK-X');
      expect(res.cleanHeader, 'HDFCBK');
      expect(res.suffix, isNull); // 'X' is not valid TRAI suffix
    });

    test(
      'handles phone numbers without treating as commercial header: +919876543210',
      () {
        final res = parser.parse('+919876543210');
        expect(res.rawSender, '+919876543210');
        expect(res.isCommercial, isFalse);
        expect(res.suffix, isNull);
        expect(res.operatorPrefix, isNull);
      },
    );

    test('handles 10-digit mobile number: 9876543210', () {
      final res = parser.parse('9876543210');
      expect(res.rawSender, '9876543210');
      expect(res.isCommercial, isFalse);
      expect(res.suffix, isNull);
    });

    test('gracefully handles malformed isolated suffix: -T', () {
      final res = parser.parse('-T');
      expect(res.rawSender, '-T');
      expect(res.isCommercial, isFalse);
    });

    test('gracefully handles empty and whitespace-only strings', () {
      final res1 = parser.parse('');
      expect(res1.cleanHeader, 'UNKNOWN');
      expect(res1.isCommercial, isFalse);

      final res2 = parser.parse('   ');
      expect(res2.cleanHeader, 'UNKNOWN');
      expect(res2.isCommercial, isFalse);
    });
  });
}
