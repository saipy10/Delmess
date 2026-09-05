import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/brand_resolver.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/content_rule_classifier.dart';
import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Implements the strict 4-tier Indian SMS classification hierarchy:
///
/// Priority 1 — Explicit commercial SMS suffix (-P, -S, -T, -G) [Highest, overrides all body keywords]
/// Priority 2 — Header/brand recognition
/// Priority 3 — Conservative message-content classification
/// Priority 4 — Other / Fallback
class SmsCategoryResolver {
  final BrandResolver brandResolver;
  final ContentRuleClassifier contentClassifier;

  const SmsCategoryResolver({
    required this.brandResolver,
    this.contentClassifier = const ContentRuleClassifier(),
  });

  /// Resolves the category for a message according to the priority hierarchy.
  ClassificationResult resolve({
    required ParsedHeader parsedHeader,
    required String body,
    String? detectedOtp,
    BrandInfo? brandInfo,
  }) {
    final brand = brandInfo ?? brandResolver.resolveSync(parsedHeader.cleanHeader);
    final brandName = brand?.brandName;

    // -------------------------------------------------------------
    // Priority 1 — Explicit commercial SMS suffix (-P, -S, -T, -G)
    // -------------------------------------------------------------
    if (parsedHeader.suffix != null) {
      final suffixUpper = parsedHeader.suffix!.toUpperCase();
      CategoryType? suffixCategory;

      switch (suffixUpper) {
        case 'P':
          suffixCategory = CategoryType.promotional;
          break;
        case 'S':
          suffixCategory = CategoryType.service;
          break;
        case 'T':
          suffixCategory = CategoryType.transactional;
          break;
        case 'G':
          suffixCategory = CategoryType.government;
          break;
      }

      if (suffixCategory != null) {
        // High confidence, explicit suffix wins over any body keywords!
        return ClassificationResult(
          category: suffixCategory,
          confidence: 1.0,
          reason: ClassificationReason.officialSuffix,
          reasonDescription: 'Explicit -$suffixUpper commercial SMS suffix',
          parsedHeader: parsedHeader,
          brand: brandName,
          detectedOtp: detectedOtp,
        );
      }
    }

    // -------------------------------------------------------------
    // Priority 2 — Header / brand recognition
    // -------------------------------------------------------------
    if (parsedHeader.isCommercial && brand?.defaultCategory != null) {
      return ClassificationResult(
        category: brand!.defaultCategory!,
        confidence: 0.90,
        reason: ClassificationReason.knownHeader,
        reasonDescription: 'Recognized brand header (${brand.brandName})',
        parsedHeader: parsedHeader,
        brand: brandName,
        detectedOtp: detectedOtp,
      );
    }

    // -------------------------------------------------------------
    // Priority 3 — Message-content classification (Conservative heuristics)
    // -------------------------------------------------------------
    final contentResult = contentClassifier.classify(
      body,
      parsedHeader,
      brand: brandName,
      detectedOtp: detectedOtp,
    );
    if (contentResult != null) {
      return contentResult;
    }

    // -------------------------------------------------------------
    // Priority 4 — Other / Fallback
    // -------------------------------------------------------------
    return ClassificationResult.unknown(
      parsedHeader: parsedHeader,
      brand: brandName,
      detectedOtp: detectedOtp,
    );
  }
}
