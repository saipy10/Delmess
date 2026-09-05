import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Conservative content-based fallback classification.
///
/// ONLY evaluated when official header suffix and known header metadata
/// do not definitively determine the message category.
class ContentRuleClassifier {
  const ContentRuleClassifier();

  // Transactional patterns (Financial, banking, UPI, debited/credited)
  static final RegExp _transactionalRegex = RegExp(
    r'\b(?:debited|credited|withdrawn|deposit(?:ed)?|transferred|upi|neft|rtgs|imps|inr|rs\.?|₹|a/c\s*(?:no\.?)?\s*[\dxX]+|acct\s*[\dxX]+|account\s*[\dxX]+|txn|payment\s+of|spent\s+on|received\s+payment)\b',
    caseSensitive: false,
  );

  // Government patterns
  static final RegExp _governmentRegex = RegExp(
    r'\b(?:aadhaar|uidai|cowin|income\s*tax|itr|pan\s*card|digilocker|voter\s*id|epfo|passbook|challan|e-challan|ministry\s+of|govt\s+of\s+india)\b',
    caseSensitive: false,
  );

  // Service patterns (Delivery, logistics, bookings, appointments, accounts)
  static final RegExp _serviceRegex = RegExp(
    r'\b(?:delivered|out\s+for\s+delivery|shipment|dispatched|in\s*transit|track\s+(?:your\s+)?order|order\s+(?:id|number|status|confirmed|placed)|appointment\s+(?:confirmed|scheduled|reminder)|booking\s+(?:confirmed|id)|service\s+request|flight\s+ticket|pnr\s+no|ride\s+arriving|cab\s+booked)\b',
    caseSensitive: false,
  );

  // Promotional patterns (Discounts, sales, vouchers, marketing)
  static final RegExp _promotionalRegex = RegExp(
    r'\b(?:(?:\d+%\s*off)|flat\s+\d+|discount|cashback|voucher|coupon\s*code|promo\s*code|mega\s*sale|limited\s+(?:time|period)\s+offer|shop\s+now|buy\s+now|exclusive\s+deal|hurry\s+up|avail\s+now|festive\s+offer)\b',
    caseSensitive: false,
  );

  /// Classifies message body using conservative heuristics.
  ///
  /// Returns a [ClassificationResult] if a confident pattern is identified,
  /// or `null` if the message is ambiguous/unclassified.
  ClassificationResult? classify(
    String body,
    ParsedHeader header, {
    String? brand,
    String? detectedOtp,
  }) {
    final lower = body.toLowerCase();

    // 1. Government (high priority keyword match)
    if (_governmentRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.government,
        confidence: 0.85,
        reason: ClassificationReason.contentRule,
        parsedHeader: header,
        brand: brand,
        detectedOtp: detectedOtp,
      );
    }

    // 2. Transactional (financial alerts)
    if (_transactionalRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.transactional,
        confidence: 0.80,
        reason: ClassificationReason.contentRule,
        parsedHeader: header,
        brand: brand,
        detectedOtp: detectedOtp,
      );
    }

    // 3. Service (deliveries, bookings, appointments)
    if (_serviceRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.service,
        confidence: 0.75,
        reason: ClassificationReason.contentRule,
        parsedHeader: header,
        brand: brand,
        detectedOtp: detectedOtp,
      );
    }

    // 4. Promotional (marketing, sales)
    if (_promotionalRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.promotional,
        confidence: 0.75,
        reason: ClassificationReason.contentRule,
        parsedHeader: header,
        brand: brand,
        detectedOtp: detectedOtp,
      );
    }

    // If only OTP is present without financial context, consider it service (login verification)
    if (detectedOtp != null &&
        (lower.contains('verification') ||
            lower.contains('otp') ||
            lower.contains('login') ||
            lower.contains('code'))) {
      return ClassificationResult(
        category: CategoryType.service,
        confidence: 0.70,
        reason: ClassificationReason.contentRule,
        parsedHeader: header,
        brand: brand,
        detectedOtp: detectedOtp,
      );
    }

    return null;
  }
}
