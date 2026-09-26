import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmsMessage Domain Model Tests', () {
    final now = DateTime(2026, 9, 1, 12, 0, 0);

    test('creates SmsMessage with required fields and defaults', () {
      final msg = SmsMessage(
        id: 'msg_1',
        threadId: 'thread_1',
        sender: 'AD-HDFCBK-T',
        header: 'HDFCBK',
        body: 'OTP is 123456',
        receivedAt: now,
        category: CategoryType.transactional,
        createdAt: now,
        updatedAt: now,
      );

      expect(msg.id, 'msg_1');
      expect(msg.threadId, 'thread_1');
      expect(msg.sender, 'AD-HDFCBK-T');
      expect(msg.header, 'HDFCBK');
      expect(msg.body, 'OTP is 123456');
      expect(msg.receivedAt, now);
      expect(msg.timestamp, now); // Alias test
      expect(msg.category, CategoryType.transactional);
      expect(msg.categorySource, CategorySource.fallback);
      expect(msg.isPayment, isFalse);
      expect(msg.paymentType, PaymentType.none);
      expect(msg.paymentDirection, PaymentDirection.none);
      expect(msg.paymentSource, PaymentSource.none);
      expect(msg.hasOtp, isFalse);
      expect(msg.otpSource, OtpSource.none);
      expect(msg.classificationConfidence, 1.0);
      expect(msg.classificationReason, ClassificationReason.unknown);
      expect(msg.isRead, isFalse);
      expect(msg.isStarred, isFalse);
      expect(msg.isPinned, isFalse);
      expect(msg.isArchived, isFalse);
      expect(msg.isDeleted, isFalse);
      expect(msg.otp, isNull);
      expect(msg.labels, isEmpty);
    });

    test('copyWith updates Phase 7 fields correctly without mutating original', () {
      final msg = SmsMessage(
        id: 'msg_1',
        threadId: 'thread_1',
        sender: 'AD-HDFCBK-T',
        header: 'HDFCBK',
        body: '₹1,500 debited through UPI',
        receivedAt: now,
        category: CategoryType.transactional,
        createdAt: now,
        updatedAt: now,
      );

      final updated = msg.copyWith(
        categorySource: CategorySource.traiSuffix,
        traiSuffix: 'T',
        isPayment: true,
        paymentType: PaymentType.upi,
        paymentDirection: PaymentDirection.debit,
        paymentSource: PaymentSource.paymentPattern,
        hasOtp: true,
        otpValue: '482913',
        otpSource: OtpSource.otpPattern,
        isRead: true,
        isStarred: true,
      );

      expect(updated.categorySource, 'TRAI_SUFFIX');
      expect(updated.traiSuffix, 'T');
      expect(updated.isPayment, isTrue);
      expect(updated.paymentType, PaymentType.upi);
      expect(updated.paymentDirection, PaymentDirection.debit);
      expect(updated.paymentSource, 'PAYMENT_PATTERN');
      expect(updated.hasOtp, isTrue);
      expect(updated.otpValue, '482913');
      expect(updated.otpSource, 'OTP_PATTERN');
      expect(updated.isRead, isTrue);
      expect(updated.isStarred, isTrue);
      expect(msg.isPayment, isFalse);
    });

    test(
      'state transitions work accurately (read/star/pin/archive/delete)',
      () {
        var msg = SmsMessage(
          id: 'msg_1',
          threadId: 'thread_1',
          sender: 'SWIGGY',
          header: 'SWIGGY',
          body: 'Food is on the way',
          receivedAt: now,
          category: CategoryType.service,
          createdAt: now,
          updatedAt: now,
        );

        // Read transition
        msg = msg.copyWith(isRead: true);
        expect(msg.isRead, isTrue);
        msg = msg.copyWith(isRead: false);
        expect(msg.isRead, isFalse);

        // Star transition
        msg = msg.copyWith(isStarred: true);
        expect(msg.isStarred, isTrue);
        msg = msg.copyWith(isStarred: false);
        expect(msg.isStarred, isFalse);

        // Pin transition
        msg = msg.copyWith(isPinned: true);
        expect(msg.isPinned, isTrue);
        msg = msg.copyWith(isPinned: false);
        expect(msg.isPinned, isFalse);

        // Archive transition
        msg = msg.copyWith(isArchived: true);
        expect(msg.isArchived, isTrue);
        msg = msg.copyWith(isArchived: false);
        expect(msg.isArchived, isFalse);

        // Soft delete & restore transition
        msg = msg.copyWith(isDeleted: true);
        expect(msg.isDeleted, isTrue);
        msg = msg.copyWith(isDeleted: false);
        expect(msg.isDeleted, isFalse);
      },
    );

    test('supports attaching multiple labels', () {
      final label1 = LabelModel(
        id: 'l1',
        name: 'Banking',
        createdAt: now,
        updatedAt: now,
      );
      final label2 = LabelModel(
        id: 'l2',
        name: 'Urgent',
        createdAt: now,
        updatedAt: now,
      );

      final msg = SmsMessage(
        id: 'msg_1',
        threadId: 'thread_1',
        sender: 'HDFC',
        header: 'HDFC',
        body: 'Alert',
        receivedAt: now,
        category: CategoryType.transactional,
        labels: [label1, label2],
        createdAt: now,
        updatedAt: now,
      );

      expect(msg.labels.length, 2);
      expect(msg.labels.map((l) => l.name), containsAll(['Banking', 'Urgent']));
    });
  });
}
