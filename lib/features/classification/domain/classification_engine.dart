import 'package:delmess/features/classification/domain/brand_resolver.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/content_rule_classifier.dart';
import 'package:delmess/features/classification/domain/header_parser.dart';
import 'package:delmess/features/classification/domain/header_suffix_classifier.dart';
import 'package:delmess/features/classification/domain/known_header_classifier.dart';
import 'package:delmess/features/classification/domain/otp_classifier.dart';
import 'package:delmess/features/classification/domain/sms_classifier.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Central classification engine orchestrating Indian SMS intelligence.
///
/// Follows strict hierarchical priority:
/// 1. Official TRAI suffix (-T, -S, -P, -G) [Confidence: 1.0, Priority: Highest]
/// 2. Known header metadata & brand resolution [Confidence: 0.90]
/// 3. Conservative content rules [Confidence: 0.70 - 0.85]
/// 4. Fallback / Other [Confidence: 0.0]
class ClassificationEngine {
  final HeaderParser headerParser;
  final HeaderSuffixClassifier suffixClassifier;
  final KnownHeaderClassifier knownHeaderClassifier;
  final BrandResolver brandResolver;
  final ContentRuleClassifier contentRuleClassifier;
  final OTPClassifier otpClassifier;
  final SmsClassifier? smsClassifier;

  ClassificationEngine({
    this.headerParser = const HeaderParser(),
    this.suffixClassifier = const HeaderSuffixClassifier(),
    KnownHeaderClassifier? knownHeaderClassifier,
    BrandResolver? brandResolver,
    this.contentRuleClassifier = const ContentRuleClassifier(),
    this.otpClassifier = const OTPClassifier(),
    SenderMetadataRepository? metadataRepository,
    this.smsClassifier,
  }) : knownHeaderClassifier =
           knownHeaderClassifier ??
           KnownHeaderClassifier(repository: metadataRepository),
       brandResolver =
           brandResolver ?? BrandResolver(repository: metadataRepository);

  /// Asynchronously classifies an SMS message using database metadata if needed.
  Future<ClassificationResult> classify({
    required String sender,
    required String body,
  }) async {
    // 1. Parse header
    final parsed = headerParser.parse(sender);

    // 2. Detect OTP (if present)
    final otp = otpClassifier.extractOtp(body);

    // 3. Brand / Known metadata lookup
    final meta = await knownHeaderClassifier.lookupMetadata(parsed.cleanHeader);
    final brandInfo = await brandResolver.resolve(parsed.cleanHeader);
    final brand = meta?.brand ?? brandInfo?.brandName;

    // 4. Priority 1: Official Suffix (Always wins over body keywords)
    final suffixResult = suffixClassifier.classify(
      parsed,
      brand: brand,
      detectedOtp: otp,
    );
    if (suffixResult != null) {
      return suffixResult;
    }

    // 5. Priority 2: Known Header Database Metadata & Brand Resolution
    final knownResult = knownHeaderClassifier.classifyWithMetadata(
      parsed,
      meta,
      detectedOtp: otp,
    );
    if (knownResult != null) {
      return knownResult;
    }

    if (parsed.isCommercial && brandInfo?.defaultCategory != null) {
      return ClassificationResult(
        category: brandInfo!.defaultCategory!,
        confidence: 0.90,
        reason: ClassificationReason.knownHeader,
        reasonDescription: 'Recognized brand header ($brand)',
        parsedHeader: parsed,
        brand: brand,
        detectedOtp: otp,
      );
    }

    // 6. Priority 3: Conservative Content Keyword Rules
    final contentResult = contentRuleClassifier.classify(
      body,
      parsed,
      brand: brand,
      detectedOtp: otp,
    );
    if (contentResult != null) {
      return contentResult;
    }

    // 7. Fallback: Other / Unknown
    return ClassificationResult.unknown(
      parsedHeader: parsed,
      brand: brand,
      detectedOtp: otp,
    );
  }

  /// Synchronously classifies an SMS message using in-memory cached metadata.
  ClassificationResult classifySync({
    required String sender,
    required String body,
  }) {
    final parsed = headerParser.parse(sender);
    final otp = otpClassifier.extractOtp(body);
    final meta = knownHeaderClassifier.lookupCached(parsed.cleanHeader);
    final brandInfo = brandResolver.resolveSync(parsed.cleanHeader);
    final brand = meta?.brand ?? brandInfo?.brandName;

    final suffixResult = suffixClassifier.classify(
      parsed,
      brand: brand,
      detectedOtp: otp,
    );
    if (suffixResult != null) {
      return suffixResult;
    }

    final knownResult = knownHeaderClassifier.classifyWithMetadata(
      parsed,
      meta,
      detectedOtp: otp,
    );
    if (knownResult != null) {
      return knownResult;
    }

    if (parsed.isCommercial && brandInfo?.defaultCategory != null) {
      return ClassificationResult(
        category: brandInfo!.defaultCategory!,
        confidence: 0.90,
        reason: ClassificationReason.knownHeader,
        reasonDescription: 'Recognized brand header ($brand)',
        parsedHeader: parsed,
        brand: brand,
        detectedOtp: otp,
      );
    }

    final contentResult = contentRuleClassifier.classify(
      body,
      parsed,
      brand: brand,
      detectedOtp: otp,
    );
    if (contentResult != null) {
      return contentResult;
    }

    return ClassificationResult.unknown(
      parsedHeader: parsed,
      brand: brand,
      detectedOtp: otp,
    );
  }
}
