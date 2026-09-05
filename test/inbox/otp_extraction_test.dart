import 'package:delmess/core/utils/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 5 OTP Extraction & Formatting Tests', () {
    test('extracts OTP from standard Indian commercial banking message', () {
      const msg =
          'Your OTP for transaction of INR 4,999.00 at AMAZON INDIA is 482921. Valid for 10 minutes. Do not share with anyone.';
      final otp = StringUtils.extractOtp(msg);
      expect(otp, equals('482921'));
    });

    test('extracts OTP when code is placed before "is your OTP"', () {
      const msg =
          '482913 is your OTP to login to HDFC netbanking. Valid for 5 mins.';
      final otp = StringUtils.extractOtp(msg);
      expect(otp, equals('482913'));
    });

    test('extracts OTP from "Use code X to verify" phrasing and ignores account number', () {
      const msg =
          'Use code 918234 to verify your account ending in 4321. Do not share.';
      final otp = StringUtils.extractOtp(msg);
      expect(otp, equals('918234'));
    });

    test('extracts OTP from "OTP: 123456" prefix format', () {
      const msg = 'OTP: 654321 for Swiggy delivery login.';
      final otp = StringUtils.extractOtp(msg);
      expect(otp, equals('654321'));
    });

    test('extracts OTP from "Your login verification code is 789123"', () {
      const msg = 'Your login verification code is 789123. Valid for 10 mins.';
      final otp = StringUtils.extractOtp(msg);
      expect(otp, equals('789123'));
    });

    test('returns null when message has no OTP keywords and only currency/order ids', () {
      const msg =
          'Your Swiggy order of Rs 450 with order #98234712 is out for delivery.';
      final otp = StringUtils.extractOtp(msg);
      expect(otp, isNull);
    });

    test('avoids extracting transaction amounts or minute values', () {
      const msg =
          'Your OTP is 341256 for payment of Rs 1500. Valid for 10 minutes.';
      final otp = StringUtils.extractOtp(msg);
      expect(otp, equals('341256'));
      expect(otp, isNot(equals('1500')));
      expect(otp, isNot(equals('10')));
    });
  });
}
