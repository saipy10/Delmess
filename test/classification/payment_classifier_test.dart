import 'package:delmess/features/classification/domain/payment_classifier.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 7.16 Suite B — Payment Classification Tests', () {
    const classifier = PaymentClassifier();

    group('Positive Payment Events', () {
      test('Debit -> Payment: Yes, Type: Debit, Direction: Debit', () {
        final result = classifier.classify(
          '₹5,000 debited from your account.',
        );

        expect(result.isPayment, isTrue);
        expect(result.direction, PaymentDirection.debit);
        expect(result.type, PaymentType.debit);
        expect(result.source, PaymentSource.paymentPattern);
      });

      test('Credit -> Payment: Yes, Type: Credit, Direction: Credit', () {
        final result = classifier.classify(
          '₹10,000 credited to your A/c XX5678.',
        );

        expect(result.isPayment, isTrue);
        expect(result.direction, PaymentDirection.credit);
        expect(result.type, PaymentType.credit);
      });

      test('UPI -> Payment: Yes, Type: UPI', () {
        final result = classifier.classify(
          '₹1,500 debited through UPI to merchant@okhdfcbank.',
        );

        expect(result.isPayment, isTrue);
        expect(result.type, PaymentType.upi);
        expect(result.direction, PaymentDirection.debit);
      });

      test('Card charge -> Payment: Yes, Type: Card', () {
        final result = classifier.classify(
          'Your credit card was charged ₹4,500 at Croma Electronics.',
        );

        expect(result.isPayment, isTrue);
        expect(result.type, PaymentType.card);
        expect(result.direction, PaymentDirection.debit);
      });

      test('Refund -> Payment: Yes, Type: Refund', () {
        final result = classifier.classify(
          'Refund of ₹1,200 credited to your account XX9821.',
        );

        expect(result.isPayment, isTrue);
        expect(result.type, PaymentType.refund);
        expect(result.direction, PaymentDirection.credit);
      });

      test('Cash Withdrawal -> Payment: Yes, Type: Cash Withdrawal', () {
        final result = classifier.classify(
          'Cash withdrawal of ₹2,000 from ATM completed.',
        );

        expect(result.isPayment, isTrue);
        expect(result.type, PaymentType.cashWithdrawal);
        expect(result.direction, PaymentDirection.debit);
      });

      test('Bank Transfer -> Payment: Yes, Type: Bank Transfer', () {
        final result = classifier.classify(
          'NEFT transfer of ₹25,000 sent to A/c 9876 successful.',
        );

        expect(result.isPayment, isTrue);
        expect(result.type, PaymentType.bankTransfer);
        expect(result.direction, PaymentDirection.debit);
      });

      test('Electricity bill payment -> Payment: Yes, Type: Bill Payment', () {
        final result = classifier.classify(
          'Electricity bill payment of ₹2,000 successful.',
        );

        expect(result.isPayment, isTrue);
        expect(result.type, PaymentType.billPayment);
      });

      test('Mobile recharge -> Payment: Yes, Type: Recharge', () {
        final result = classifier.classify(
          'Mobile recharge of ₹299 successful for 9876543210.',
        );

        expect(result.isPayment, isTrue);
        expect(result.type, PaymentType.recharge);
      });
    });

    group('False-Positive Protection (Must be Payment: No)', () {
      test('Offer containing "payment" -> Not Payment ("Get 10% cashback on UPI payments")', () {
        final result = classifier.classify(
          'Get 10% cashback on UPI payments using our app.',
        );

        expect(result.isPayment, isFalse);
        expect(result.type, PaymentType.none);
        expect(result.direction, PaymentDirection.none);
      });

      test('Next payment offer -> Not Payment ("Get 5% cashback on your next UPI payment.")', () {
        final result = classifier.classify(
          'Get 5% cashback on your next UPI payment.',
        );

        expect(result.isPayment, isFalse);
        expect(result.type, PaymentType.none);
      });

      test('Credit-card offer -> Not Payment ("Apply for our new credit card")', () {
        final result = classifier.classify(
          'Apply for our new credit card and enjoy airport lounge access!',
        );

        expect(result.isPayment, isFalse);
        expect(result.type, PaymentType.none);
      });

      test('Bill payment offer -> Not Payment ("Pay your electricity bill and get cashback")', () {
        final result = classifier.classify(
          'Pay your electricity bill and get cashback up to ₹100.',
        );

        expect(result.isPayment, isFalse);
        expect(result.type, PaymentType.none);
      });

      test('Administrative dispatch notice -> Not Payment ("Your cheque book has been dispatched")', () {
        final result = classifier.classify(
          'Your cheque book has been dispatched via speed post.',
        );

        expect(result.isPayment, isFalse);
        expect(result.type, PaymentType.none);
      });

      test('Due bill reminder -> Not Payment ("Your electricity bill is due on 25th")', () {
        final result = classifier.classify(
          'Reminder: Your electricity bill is due on 25th. Pay before due date to avoid penalty.',
        );

        expect(result.isPayment, isFalse);
      });

      test('Account statement -> Not Payment', () {
        final result = classifier.classify(
          'Your e-statement for the month of August is now ready to download.',
        );

        expect(result.isPayment, isFalse);
      });

      test('Pre-approved loan -> Not Payment', () {
        final result = classifier.classify(
          'Congratulations! You have a pre-approved personal loan of ₹5,00,000. Apply now.',
        );

        expect(result.isPayment, isFalse);
      });
    });
  });
}
