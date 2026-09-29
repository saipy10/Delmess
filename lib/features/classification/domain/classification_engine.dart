import 'package:delmess/features/classification/domain/brand_resolver.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/content_rule_classifier.dart';
import 'package:delmess/features/classification/domain/header_parser.dart';
import 'package:delmess/features/classification/domain/header_suffix_classifier.dart';
import 'package:delmess/features/classification/domain/known_header_classifier.dart';
import 'package:delmess/features/classification/domain/otp_classifier.dart';
import 'package:delmess/features/classification/domain/payment_classifier.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:delmess/features/classification/domain/sms_classifier.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Central classification engine orchestrating Indian SMS intelligence.
///
/// Implements Phase 7 multi-dimensional classification architecture:
/// 1. Primary Category: Determined by TRAI suffix (-T, -S, -P, -G),
///    known header metadata, or conservative content fallbacks.
/// 2. Payment/Transaction Detection: Independent dimension answering whether
///    the message represents an actual financial transaction event.
/// 3. OTP Detection: Independent dimension with bounded scanning and false-positive guards.
/// 4. Brand Resolution: Independent lookup that does not override TRAI classification.
class ClassificationEngine {
  final HeaderParser headerParser;
  final HeaderSuffixClassifier suffixClassifier;
  final KnownHeaderClassifier knownHeaderClassifier;
  final BrandResolver brandResolver;
  final ContentRuleClassifier contentRuleClassifier;
  final OTPClassifier otpClassifier;
  final PaymentClassifier paymentClassifier;
  final SmsClassifier? smsClassifier;

  ClassificationEngine({
    this.headerParser = const HeaderParser(),
    this.suffixClassifier = const HeaderSuffixClassifier(),
    KnownHeaderClassifier? knownHeaderClassifier,
    BrandResolver? brandResolver,
    this.contentRuleClassifier = const ContentRuleClassifier(),
    this.otpClassifier = const OTPClassifier(),
    this.paymentClassifier = const PaymentClassifier(),
    SenderMetadataRepository? metadataRepository,
    this.smsClassifier,
  }) : knownHeaderClassifier =
           knownHeaderClassifier ??
           KnownHeaderClassifier(repository: metadataRepository),
       brandResolver =
           brandResolver ?? BrandResolver(repository: metadataRepository);

  /// Asynchronously classifies an SMS message across all independent dimensions.
  Future<ClassificationResult> classify({
    required String sender,
    required String body,
  }) async {
    // 1. Parse header (TRAI operator prefix, clean header, suffix)
    final parsed = headerParser.parse(sender);

    // 2. Independent Payment Detector: Evaluates financial transaction execution
    final payment = paymentClassifier.classify(body, parsedHeader: parsed);

    // 3. Independent OTP Detector: Bounded scan with false-positive safeguards
    final otp = otpClassifier.classify(body);

    // 4. Headers are preserved directly without mapping to arbitrary names
    final meta = await knownHeaderClassifier.lookupMetadata(parsed.cleanHeader);
    final brandInfo = await brandResolver.resolve(parsed.cleanHeader);
    final rawBrand = meta?.brand ?? brandInfo?.brandName;
    final brand = (rawBrand != null && rawBrand.isNotEmpty) ? rawBrand : null;

    // 5. Determine Primary Category
    // Priority 1: Official Suffix (-T, -S, -P, -G) [Highest Authority]
    final suffixResult = suffixClassifier.classify(
      parsed,
      brand: brand,
      payment: payment,
      otp: otp,
    );
    if (suffixResult != null) {
      return suffixResult;
    }

    // Priority 2: Known Header Database Metadata & Brand Resolution
    final knownResult = knownHeaderClassifier.classifyWithMetadata(
      parsed,
      meta,
      payment: payment,
      otp: otp,
    );
    if (knownResult != null) {
      return knownResult;
    }

    if (parsed.isCommercial && brandInfo?.defaultCategory != null) {
      return ClassificationResult(
        category: brandInfo!.defaultCategory!,
        categorySource: CategorySource.knownHeader,
        confidence: 0.90,
        reason: ClassificationReason.knownHeader,
        reasonDescription: 'Recognized header (${parsed.cleanHeader})',
        parsedHeader: parsed,
        brand: brand,
        payment: payment,
        otp: otp,
      );
    }

    // Priority 3: Conservative Content Keyword Rules
    final contentResult = contentRuleClassifier.classify(
      body,
      parsed,
      brand: brand,
      payment: payment,
      otp: otp,
    );
    if (contentResult != null) {
      return contentResult;
    }

    // Fallback: Other / Unknown
    return ClassificationResult.unknown(
      parsedHeader: parsed,
      brand: brand,
      payment: payment,
      otp: otp,
    );
  }

  /// Synchronously classifies an SMS message using in-memory cached metadata.
  ClassificationResult classifySync({
    required String sender,
    required String body,
  }) {
    final parsed = headerParser.parse(sender);
    final payment = paymentClassifier.classify(body, parsedHeader: parsed);
    final otp = otpClassifier.classify(body);
    final meta = knownHeaderClassifier.lookupCached(parsed.cleanHeader);
    final brandInfo = brandResolver.resolveSync(parsed.cleanHeader);
    final rawBrand = meta?.brand ?? brandInfo?.brandName;
    final brand = (rawBrand != null && rawBrand.isNotEmpty) ? rawBrand : null;

    final suffixResult = suffixClassifier.classify(
      parsed,
      brand: brand,
      payment: payment,
      otp: otp,
    );
    if (suffixResult != null) {
      return suffixResult;
    }

    final knownResult = knownHeaderClassifier.classifyWithMetadata(
      parsed,
      meta,
      payment: payment,
      otp: otp,
    );
    if (knownResult != null) {
      return knownResult;
    }

    if (parsed.isCommercial && brandInfo?.defaultCategory != null) {
      return ClassificationResult(
        category: brandInfo!.defaultCategory!,
        categorySource: CategorySource.knownHeader,
        confidence: 0.90,
        reason: ClassificationReason.knownHeader,
        reasonDescription: 'Recognized header (${parsed.cleanHeader})',
        parsedHeader: parsed,
        brand: brand,
        payment: payment,
        otp: otp,
      );
    }

    final contentResult = contentRuleClassifier.classify(
      body,
      parsed,
      brand: brand,
      payment: payment,
      otp: otp,
    );
    if (contentResult != null) {
      return contentResult;
    }

    return ClassificationResult.unknown(
      parsedHeader: parsed,
      brand: brand,
      payment: payment,
      otp: otp,
    );
  }
}
