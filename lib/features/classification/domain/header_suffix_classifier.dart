import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Classifies messages based on official TRAI SMS header suffixes (-T, -S, -P, -G).
///
/// Under Indian SMS regulations, the official suffix represents the highest-priority
/// classification signal and cannot be overridden by message content or heuristics.
class HeaderSuffixClassifier {
  const HeaderSuffixClassifier();

  /// Attempts to classify a message solely from its parsed header suffix.
  ///
  /// Returns a [ClassificationResult] if a recognized suffix is present, or `null` if not.
  ClassificationResult? classify(
    ParsedHeader header, {
    String? brand,
    String? detectedOtp,
  }) {
    if (header.suffix == null) return null;

    final CategoryType? category;
    switch (header.suffix) {
      case 'T':
        category = CategoryType.transactional;
        break;
      case 'S':
        category = CategoryType.service;
        break;
      case 'P':
        category = CategoryType.promotional;
        break;
      case 'G':
        category = CategoryType.government;
        break;
      default:
        category = null;
    }

    if (category == null) return null;

    return ClassificationResult(
      category: category,
      confidence: 1.0,
      reason: ClassificationReason.officialSuffix,
      reasonDescription: 'Explicit -${header.suffix} commercial SMS suffix',
      parsedHeader: header,
      brand: brand,
      detectedOtp: detectedOtp,
    );
  }
}
