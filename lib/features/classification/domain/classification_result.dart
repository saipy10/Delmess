import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Structured result of the SMS intelligence and classification process.
class ClassificationResult {
  final CategoryType category;
  final double confidence;
  final ClassificationReason reason;
  final String? reasonDescription;
  final ParsedHeader parsedHeader;
  final String? brand;
  final String? detectedOtp;

  const ClassificationResult({
    required this.category,
    required this.confidence,
    required this.reason,
    this.reasonDescription,
    required this.parsedHeader,
    this.brand,
    this.detectedOtp,
  });

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
    String? reasonDescription,
  }) {
    return ClassificationResult(
      category: CategoryType.other,
      confidence: 0.0,
      reason: ClassificationReason.unknown,
      reasonDescription: reasonDescription ?? 'Unclassified / Fallback',
      parsedHeader: parsedHeader,
      brand: brand,
      detectedOtp: detectedOtp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationResult &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          confidence == other.confidence &&
          reason == other.reason &&
          parsedHeader == other.parsedHeader &&
          brand == other.brand &&
          detectedOtp == other.detectedOtp;

  @override
  int get hashCode =>
      category.hashCode ^
      confidence.hashCode ^
      reason.hashCode ^
      parsedHeader.hashCode ^
      brand.hashCode ^
      detectedOtp.hashCode;

  @override
  String toString() =>
      'ClassificationResult(category: ${category.name}, confidence: $confidence, reason: ${reason.name}, brand: $brand, otp: $detectedOtp)';
}
