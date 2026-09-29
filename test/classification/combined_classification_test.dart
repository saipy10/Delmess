import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/classification_engine.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 7.17 Combined Classification Tests', () {
    late ClassificationEngine engine;

    setUp(() {
      engine = ClassificationEngine();
    });

    test('Bank debit -> TRAI: Transactional, Payment: Yes (Debit), OTP: No', () async {
      // AD-HDFCBK-T: ₹5,000 debited from your account
      final result = await engine.classify(
        sender: 'AD-HDFCBK-T',
        body: '₹5,000 debited from your account XX1234 on 26-Sep.',
      );

      expect(result.category, CategoryType.transactional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'T');
      expect(result.isPayment, isTrue);
      expect(result.paymentType, PaymentType.debit);
      expect(result.paymentDirection, PaymentDirection.debit);
      expect(result.paymentSource, PaymentSource.paymentPattern);
      expect(result.hasOtp, isFalse);
      expect(result.detectedOtp, isNull);
      expect(result.brand, isNull);
    });

    test('Bank OTP -> TRAI: Service, Payment: No, OTP: Yes', () async {
      // AD-HDFCBK-S: Your OTP is 482913
      final result = await engine.classify(
        sender: 'AD-HDFCBK-S',
        body: 'Your OTP is 482913 for netbanking login.',
      );

      expect(result.category, CategoryType.service);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'S');
      expect(result.isPayment, isFalse);
      expect(result.paymentType, PaymentType.none);
      expect(result.hasOtp, isTrue);
      expect(result.detectedOtp, '482913');
      expect(result.otpSource, OtpSource.otpPattern);
      expect(result.brand, isNull);
    });

    test('UPI payment OTP -> TRAI: Service, Payment: Yes (Authorization), OTP: Yes', () async {
      // AD-HDFCBK-S: OTP for payment of ₹500 via UPI is 482913
      final result = await engine.classify(
        sender: 'AD-HDFCBK-S',
        body: 'OTP for payment of ₹500 via UPI is 482913. Do not share.',
      );

      expect(result.category, CategoryType.service);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'S');
      expect(result.isPayment, isTrue);
      expect(result.paymentType, PaymentType.upi);
      expect(result.hasOtp, isTrue);
      expect(result.detectedOtp, '482913');
      expect(result.brand, isNull);
    });

    test('Credit-card offer -> TRAI: Promotional, Payment: No, OTP: No', () async {
      // AD-HDFCBK-P: Apply for our new credit card
      final result = await engine.classify(
        sender: 'AD-HDFCBK-P',
        body: 'Apply for our new credit card and get ₹1,000 welcome voucher!',
      );

      expect(result.category, CategoryType.promotional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'P');
      expect(result.isPayment, isFalse);
      expect(result.hasOtp, isFalse);
      expect(result.brand, isNull);
    });

    test('Cashback offer -> TRAI: Promotional, Payment: No, OTP: No', () async {
      // AD-HDFCBK-P: Get 5% cashback on your next UPI payment.
      final result = await engine.classify(
        sender: 'AD-HDFCBK-P',
        body: 'Get 5% cashback on your next UPI payment. Offer valid today.',
      );

      expect(result.category, CategoryType.promotional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'P');
      expect(result.isPayment, isFalse);
      expect(result.hasOtp, isFalse);
      expect(result.brand, isNull);
    });

    test('Refund received -> TRAI: Transactional, Payment: Yes (Credit/Refund), OTP: No', () async {
      // AD-HDFCBK-T: Refund of ₹1,200 credited to account
      final result = await engine.classify(
        sender: 'AD-HDFCBK-T',
        body: 'Refund of ₹1,200 processed and credited to your account XX9821.',
      );

      expect(result.category, CategoryType.transactional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'T');
      expect(result.isPayment, isTrue);
      expect(result.paymentType, PaymentType.refund);
      expect(result.paymentDirection, PaymentDirection.credit);
      expect(result.hasOtp, isFalse);
    });

    test('Delivery OTP -> TRAI: Service, Payment: No, OTP: Yes', () async {
      // AD-SWIGGY-S: Your Swiggy delivery OTP is 9182
      final result = await engine.classify(
        sender: 'AD-SWIGGY-S',
        body: 'Your Swiggy delivery OTP is 9182. Share with delivery partner.',
      );

      expect(result.category, CategoryType.service);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'S');
      expect(result.isPayment, isFalse);
      expect(result.hasOtp, isTrue);
      expect(result.detectedOtp, '9182');
      expect(result.brand, isNull);
    });

    test('Government OTP -> TRAI: Government, Payment: No, OTP: Yes', () async {
      // XX-GOVT-G: Aadhaar verification code is 829103
      final result = await engine.classify(
        sender: 'XX-GOVT-G',
        body: 'Your Aadhaar verification code is 829103 for e-KYC authentication.',
      );

      expect(result.category, CategoryType.government);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'G');
      expect(result.isPayment, isFalse);
      expect(result.hasOtp, isTrue);
      expect(result.detectedOtp, '829103');
    });

    test('Bank Transactional Non-Payment -> Category: Transactional, Payment: No, OTP: No', () async {
      // AD-HDFCBK-T: Your cheque book has been dispatched
      final result = await engine.classify(
        sender: 'AD-HDFCBK-T',
        body: 'Your cheque book has been dispatched via speed post.',
      );

      expect(result.category, CategoryType.transactional);
      expect(result.categorySource, CategorySource.traiSuffix);
      expect(result.traiSuffix, 'T');
      expect(result.isPayment, isFalse);
      expect(result.hasOtp, isFalse);
      expect(result.brand, isNull);
    });

    test('Electricity bill payment -> Category: Transactional, Payment: Yes, Type: Bill Payment', () async {
      // AD-HDFCBK-T: Electricity bill payment of ₹2,000 successful
      final result = await engine.classify(
        sender: 'AD-HDFCBK-T',
        body: 'Electricity bill payment of ₹2,000 successful for consumer 482910.',
      );

      expect(result.category, CategoryType.transactional);
      expect(result.isPayment, isTrue);
      expect(result.paymentType, PaymentType.billPayment);
    });
  });
}
