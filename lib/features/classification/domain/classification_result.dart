import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/otp_result.dart';
import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/classification/domain/payment_result.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Structured result of the SMS intelligence and classification process.
///
/// Encapsulates three independent dimensions:
/// 1. Primary Category (determined by TRAI suffix, known header metadata, or content fallback)
/// 2. Payment/Transaction Detection (does this message represent a financial transaction?)
/// 3. OTP Detection (bounded scan with false-positive safeguards)
class ClassificationResult {
  final CategoryType category;
  final String categorySource;
  final String? traiSuffix;
  final ParsedHeader parsedHeader;
  final String? brand;

  // Independent classification dimensions
  final PaymentResult payment;
  final OtpResult otp;

  // Compatibility fields
  final double confidence;
  final ClassificationReason reason;
  final String? reasonDescription;

  const ClassificationResult({
    required this.category,
    this.categorySource = CategorySource.fallback,
    this.traiSuffix,
    required this.parsedHeader,
    this.brand,
    this.payment = const PaymentResult.none(),
    this.otp = const OtpResult.none(),
    this.confidence = 1.0,
    this.reason = ClassificationReason.unknown,
    this.reasonDescription,
    String? detectedOtp,
  }) : _detectedOtpCompat = detectedOtp;

  final String? _detectedOtpCompat;

  // Convenient getters
  bool get isPayment => payment.isPayment;
  PaymentType get paymentType => payment.type;
  PaymentDirection get paymentDirection => payment.direction;
  String get paymentSource => payment.source;

  bool get hasOtp => otp.hasOtp;
  String? get detectedOtp => otp.otpValue ?? _detectedOtpCompat;
  String get otpSource => otp.source;

  String get brandName => brand ?? '';

  String get confidenceLevel {
    if (confidence >= 0.90) return 'high';
    if (confidence >= 0.70) return 'medium';
    return 'low';
  }

  String get effectiveReason => reasonDescription ?? reason.displayName;

  /// Factory for unclassified/fallback result.
  factory ClassificationResult.unknown({
    required ParsedHeader parsedHeader,
    String? brand,
    String? detectedOtp,
    PaymentResult payment = const PaymentResult.none(),
    OtpResult? otp,
    String? reasonDescription,
  }) {
    final resolvedOtp =
        otp ??
        (detectedOtp != null
            ? OtpResult(
                hasOtp: true,
                otpValue: detectedOtp,
                source: OtpSource.otpPattern,
              )
            : const OtpResult.none());

    return ClassificationResult(
      category: CategoryType.other,
      categorySource: CategorySource.fallback,
      traiSuffix: null,
      confidence: 0.0,
      reason: ClassificationReason.unknown,
      reasonDescription: reasonDescription ?? 'Unclassified / Fallback',
      parsedHeader: parsedHeader,
      brand: brand,
      payment: payment,
      otp: resolvedOtp,
    );
  }

  ClassificationResult copyWith({
    CategoryType? category,
    String? categorySource,
    String? traiSuffix,
    ParsedHeader? parsedHeader,
    String? brand,
    PaymentResult? payment,
    OtpResult? otp,
    double? confidence,
    ClassificationReason? reason,
    String? reasonDescription,
  }) {
    return ClassificationResult(
      category: category ?? this.category,
      categorySource: categorySource ?? this.categorySource,
      traiSuffix: traiSuffix ?? this.traiSuffix,
      parsedHeader: parsedHeader ?? this.parsedHeader,
      brand: brand ?? this.brand,
      payment: payment ?? this.payment,
      otp: otp ?? this.otp,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      reasonDescription: reasonDescription ?? this.reasonDescription,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationResult &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          categorySource == other.categorySource &&
          traiSuffix == other.traiSuffix &&
          confidence == other.confidence &&
          reason == other.reason &&
          parsedHeader == other.parsedHeader &&
          brand == other.brand &&
          payment == other.payment &&
          otp == other.otp;

  @override
  int get hashCode =>
      category.hashCode ^
      categorySource.hashCode ^
      traiSuffix.hashCode ^
      confidence.hashCode ^
      reason.hashCode ^
      parsedHeader.hashCode ^
      brand.hashCode ^
      payment.hashCode ^
      otp.hashCode;

  @override
  String toString() =>
      'ClassificationResult(category: ${category.name}, source: $categorySource, traiSuffix: $traiSuffix, isPayment: $isPayment, paymentType: ${paymentType.displayName}, hasOtp: $hasOtp, otp: $detectedOtp, brand: $brand)';
}
