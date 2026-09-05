import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/messages/data/sms_normalizer.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmsNormalizer Tests', () {
    test('normalizes RawSmsMessage preserving verbatim sender and body', () {
      const raw = RawSmsMessage(
        id: '12345',
        threadId: '987',
        sender: 'AD-HDFCBK-T',
        body:
            'Rs. 450.00 debited from a/c **1234 on 01-Sep-26. Info: UPI/52391/Zomato. Bal: Rs. 14,230.50',
        receivedAtMillis: 1756730000000,
        isRead: false,
      );

      final msg = SmsNormalizer.normalize(raw);

      expect(msg.id, '12345');
      expect(msg.threadId, '987');
      // Original sender and prefix/suffix preserved exactly
      expect(msg.sender, 'AD-HDFCBK-T');
      expect(msg.header, 'AD-HDFCBK-T');
      // No brand resolution or classification yet
      expect(msg.brand, isNull);
      expect(msg.category, CategoryType.other);
      expect(msg.classificationConfidence, 1.0);
      expect(msg.classificationReason, ClassificationReason.unknown);
      // Raw body preserved intact
      expect(
        msg.body,
        'Rs. 450.00 debited from a/c **1234 on 01-Sep-26. Info: UPI/52391/Zomato. Bal: Rs. 14,230.50',
      );
      expect(msg.receivedAt.millisecondsSinceEpoch, 1756730000000);
      expect(msg.isRead, false);
      expect(msg.isStarred, false);
      expect(msg.isArchived, false);
      expect(msg.isDeleted, false);
      expect(msg.otp, isNull);
    });

    test('handles fallback IDs and empty thread IDs safely', () {
      const raw = RawSmsMessage(
        id: '',
        threadId: '',
        sender: '',
        body: 'Test content',
        receivedAtMillis: 1756730000000,
        isRead: true,
      );

      final msg = SmsNormalizer.normalize(raw);

      expect(msg.id, 'sms_1756730000000');
      expect(msg.threadId, 'thread_1756730000000');
      expect(msg.sender, 'Unknown');
      expect(msg.isRead, true);
    });

    test('normalizeBatch converts entire collection correctly', () {
      final batch = [
        const RawSmsMessage(
          id: '1',
          threadId: 't1',
          sender: 'AD-HDFCBK-T',
          body: 'OTP 1234',
          receivedAtMillis: 1700000000000,
          isRead: true,
        ),
        const RawSmsMessage(
          id: '2',
          threadId: 't2',
          sender: 'BZ-SWIGGY-P',
          body: 'Special offer',
          receivedAtMillis: 1700000010000,
          isRead: false,
        ),
      ];

      final normalized = SmsNormalizer.normalizeBatch(batch);
      expect(normalized.length, 2);
      expect(normalized[0].id, '1');
      expect(normalized[0].isRead, true);
      expect(normalized[1].id, '2');
      expect(normalized[1].isRead, false);
    });
  });
}
