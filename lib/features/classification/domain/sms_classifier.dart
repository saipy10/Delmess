import 'package:delmess/features/classification/domain/brand_resolver.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/otp_classifier.dart';
import 'package:delmess/features/classification/domain/sms_category_resolver.dart';
import 'package:delmess/features/classification/domain/sms_header_parser.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';

/// Central SMS classifier orchestrating Indian commercial SMS intelligence.
///
/// Follows the strict priority pipeline:
/// Priority 1 — Explicit commercial SMS suffix (-P, -S, -T, -G) [Highest, overrides body keywords]
/// Priority 2 — Header / brand recognition (e.g. HDFCBN -> HDFC Bank, Transactional)
/// Priority 3 — Conservative message-content classification
/// Priority 4 — Other / Fallback
class SmsClassifier {
  final SmsHeaderParser headerParser;
  final BrandResolver brandResolver;
  final SmsCategoryResolver categoryResolver;
  final OTPClassifier otpClassifier;

  SmsClassifier({
    this.headerParser = const SmsHeaderParser(),
    BrandResolver? brandResolver,
    SmsCategoryResolver? categoryResolver,
    this.otpClassifier = const OTPClassifier(),
    SenderMetadataRepository? metadataRepository,
  }) : brandResolver =
           brandResolver ?? BrandResolver(repository: metadataRepository),
       categoryResolver =
           categoryResolver ??
           SmsCategoryResolver(
             brandResolver:
                 brandResolver ?? BrandResolver(repository: metadataRepository),
           );

  /// Asynchronously classifies an SMS message using database metadata when available.
  Future<ClassificationResult> classify({
    required String sender,
    required String body,
  }) async {
    // 1. Parse header
    final parsed = headerParser.parse(sender);

    // 2. Extract OTP (if present)
    final otp = otpClassifier.extractOtp(body);

    // 3. Resolve brand metadata
    final brandInfo = await brandResolver.resolve(parsed.cleanHeader);

    // 4. Resolve category through strict 4-tier hierarchy
    return categoryResolver.resolve(
      parsedHeader: parsed,
      body: body,
      detectedOtp: otp,
      brandInfo: brandInfo,
    );
  }

  /// Synchronously classifies an SMS message using in-memory cached brand knowledge.
  ClassificationResult classifySync({
    required String sender,
    required String body,
  }) {
    final parsed = headerParser.parse(sender);
    final otp = otpClassifier.extractOtp(body);
    final brandInfo = brandResolver.resolveSync(parsed.cleanHeader);

    return categoryResolver.resolve(
      parsedHeader: parsed,
      body: body,
      detectedOtp: otp,
      brandInfo: brandInfo,
    );
  }
}
