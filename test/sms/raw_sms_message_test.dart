import 'package:delmess/features/messages/domain/raw_sms_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RawSmsMessage DTO Tests', () {
    test('creates RawSmsMessage and serializes to Map', () {
      final raw = RawSmsMessage(
        id: 'msg_100',
        threadId: 'thread_10',
        sender: 'AD-HDFCBK-T',
        body: 'Your OTP is 998811.',
        receivedAtMillis: 1700000000000,
        isRead: true,
      );

      final map = raw.toMap();
      expect(map['id'], 'msg_100');
      expect(map['threadId'], 'thread_10');
      expect(map['sender'], 'AD-HDFCBK-T');
      expect(map['body'], 'Your OTP is 998811.');
      expect(map['receivedAt'], 1700000000000);
      expect(map['isRead'], true);
    });

    test('deserializes from Map with type conversions and safe defaults', () {
      final map = {
        'id': 'msg_200',
        'threadId': 'thread_20',
        'sender': 'BZ-SWIGGY-P',
        'body': '50% off on your next order!',
        'receivedAt': 1700000005000,
        'isRead': 1,
      };

      final raw = RawSmsMessage.fromMap(map);
      expect(raw.id, 'msg_200');
      expect(raw.threadId, 'thread_20');
      expect(raw.sender, 'BZ-SWIGGY-P');
      expect(raw.body, '50% off on your next order!');
      expect(raw.receivedAtMillis, 1700000005000);
      expect(raw.isRead, true);
    });

    test('handles missing or null map values safely', () {
      final raw = RawSmsMessage.fromMap({});
      expect(raw.id, '');
      expect(raw.sender, 'Unknown');
      expect(raw.body, '');
      expect(raw.isRead, false);
      expect(raw.receivedAtMillis, isPositive);
    });

    test('supports value equality and hashCode', () {
      const raw1 = RawSmsMessage(
        id: '1',
        threadId: 't1',
        sender: 'A',
        body: 'B',
        receivedAtMillis: 100,
        isRead: false,
      );
      const raw2 = RawSmsMessage(
        id: '1',
        threadId: 't1',
        sender: 'A',
        body: 'B',
        receivedAtMillis: 100,
        isRead: false,
      );

      expect(raw1, equals(raw2));
      expect(raw1.hashCode, equals(raw2.hashCode));
    });
  });
}
