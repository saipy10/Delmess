import 'package:delmess/features/classification/domain/otp_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late OTPClassifier otpClassifier;

  setUp(() {
    otpClassifier = const OTPClassifier();
  });

  group('OTP Detection Tests', () {
    test('extracts 6-digit OTP from standard phrase: Your OTP is 482921.', () {
      final code = otpClassifier.extractOtp('Your OTP is 482921.');
      expect(code, '482921');
    });

    test('extracts verification code: Your verification code is 123456.', () {
      final code = otpClassifier.extractOtp(
        'Your verification code is 123456. Valid for 10 minutes.',
      );
      expect(code, '123456');
    });

    test('extracts authentication code with code before keyword', () {
      final code = otpClassifier.extractOtp(
        'Use 839201 as your authentication code to login.',
      );
      expect(code, '839201');
    });

    test('extracts 4-digit passcode: Your passcode is 9821.', () {
      final code = otpClassifier.extractOtp('Your passcode is 9821.');
      expect(code, '9821');
    });

    test('extracts 8-digit security code', () {
      final code = otpClassifier.extractOtp(
        'One-time password: 83920184. Do not share with anyone.',
      );
      expect(code, '83920184');
    });
  });

  group('OTP False-Positive Protection Tests', () {
    test(
      'does NOT identify order number as OTP: Your order number is 123456.',
      () {
        final code = otpClassifier.extractOtp(
          'Your order number is 123456. It has been shipped.',
        );
        expect(code, isNull);
      },
    );

    test('does NOT identify phone numbers as OTP: Call us at 9876543210.', () {
      final code = otpClassifier.extractOtp(
        'For queries, call us at 9876543210 immediately.',
      );
      expect(code, isNull);
    });

    test(
      'does NOT identify currency amount as OTP: Amount ₹5,000 debited.',
      () {
        final code = otpClassifier.extractOtp(
          'Amount ₹5,000 has been debited from your account.',
        );
        expect(code, isNull);
      },
    );

    test(
      'does NOT identify bank account suffix as OTP: Account ending 1234.',
      () {
        final code = otpClassifier.extractOtp(
          'Statement for account ending 1234 has been generated.',
        );
        expect(code, isNull);
      },
    );

    test(
      'selects only the true OTP when mixed with currency, account, and date',
      () {
        const msg =
            'INR 5,000.00 debited from A/C ending 4321 on 12/05/2026. '
            'Your OTP for transaction authorization is 948215. Do not share OTP.';
        final code = otpClassifier.extractOtp(msg);
        expect(code, '948215');
      },
    );
  });
}
