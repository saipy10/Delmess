import 'package:delmess/features/classification/domain/otp_classifier.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 7.16 Suite C — OTP Classification & Safeguards Tests', () {
    const classifier = OTPClassifier();

    group('Positive OTP Detection', () {
      test('"OTP is 123456" -> OTP: Yes (123456)', () {
        final result = classifier.classify('Your OTP is 123456.');

        expect(result.hasOtp, isTrue);
        expect(result.otpValue, '123456');
        expect(result.source, OtpSource.otpPattern);
      });

      test('"verification code 123456" -> OTP: Yes (123456)', () {
        final result = classifier.classify(
          'Your verification code is 123456. Do not share it with anyone.',
        );

        expect(result.hasOtp, isTrue);
        expect(result.otpValue, '123456');
      });

      test('authentication code with code first -> OTP: Yes', () {
        final result = classifier.classify(
          'Use 839201 as your authentication code to login.',
        );

        expect(result.hasOtp, isTrue);
        expect(result.otpValue, '839201');
      });

      test('4-digit passcode -> OTP: Yes', () {
        final result = classifier.classify('Your passcode is 9821.');

        expect(result.hasOtp, isTrue);
        expect(result.otpValue, '9821');
      });

      test('8-digit security code -> OTP: Yes', () {
        final result = classifier.classify(
          '83920145 is your security code for verification.',
        );

        expect(result.hasOtp, isTrue);
        expect(result.otpValue, '83920145');
      });
    });

    group('OTP False-Positive Protection', () {
      test('"order number 123456" -> Not OTP', () {
        final result = classifier.classify('Your order number is 123456.');

        expect(result.hasOtp, isFalse);
        expect(result.otpValue, isNull);
      });

      test('"account ending 1234" -> Not OTP', () {
        final result = classifier.classify(
          'Transaction completed on account ending 1234.',
        );

        expect(result.hasOtp, isFalse);
        expect(result.otpValue, isNull);
      });

      test('phone numbers -> Not OTP ("Call us at 9876543210")', () {
        final result = classifier.classify(
          'For any query call us at 9876543210.',
        );

        expect(result.hasOtp, isFalse);
        expect(result.otpValue, isNull);
      });

      test('currency amount -> Not OTP ("Amount ₹5,000 debited")', () {
        final result = classifier.classify('Amount ₹5,000 debited from account.');

        expect(result.hasOtp, isFalse);
        expect(result.otpValue, isNull);
      });

      test('tracking ID -> Not OTP', () {
        final result = classifier.classify(
          'Your package has shipped. Tracking id: 829104.',
        );

        expect(result.hasOtp, isFalse);
      });

      test('PNR reference -> Not OTP', () {
        final result = classifier.classify(
          'Ticket booked. PNR: 482910. Train departs at 10 AM.',
        );

        expect(result.hasOtp, isFalse);
      });
    });
  });
}
