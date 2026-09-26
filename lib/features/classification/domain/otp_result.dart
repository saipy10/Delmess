import 'package:delmess/features/classification/domain/payment_type.dart';

/// Structured result of the OTP detection process.
class OtpResult {
  final bool hasOtp;
  final String? otpValue;
  final String source;

  const OtpResult({
    required this.hasOtp,
    this.otpValue,
    this.source = OtpSource.none,
  });

  const OtpResult.none()
      : hasOtp = false,
        otpValue = null,
        source = OtpSource.none;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpResult &&
          runtimeType == other.runtimeType &&
          hasOtp == other.hasOtp &&
          otpValue == other.otpValue &&
          source == other.source;

  @override
  int get hashCode => hasOtp.hashCode ^ otpValue.hashCode ^ source.hashCode;

  @override
  String toString() =>
      'OtpResult(hasOtp: $hasOtp, otpValue: $otpValue, source: $source)';
}
