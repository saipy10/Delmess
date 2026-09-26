import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/otp_result.dart';
import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/classification/domain/payment_result.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';

/// Conservative content-based fallback classification.
///
/// ONLY evaluated when official header suffix and known header metadata
/// do not definitively determine the message category.
class ContentRuleClassifier {
  const ContentRuleClassifier();

  // Transactional patterns (Financial, banking, UPI, debited/credited, Hindi/Marathi/Regional)
  static final RegExp _transactionalRegex = RegExp(
    r'(?:\b(?:debited|credited|withdrawn|deposit(?:ed)?|transferred|upi|neft|rtgs|imps|inr|rs\.?|a/c\s*(?:no\.?)?\s*[\dxX]+|acct\s*[\dxX]+|account\s*[\dxX]+|txn|payment\s+of|spent\s+on|received\s+payment)\b|₹|जमा|नावे|काढले|निकाले|खात्यात|खाते|खाता|शिल्लक|बैलेंस|शेष|செலுத்தப்பட்டது|வரவு|ఖాతా|జమ|জমা|ખાતું)',
    caseSensitive: false,
  );

  // Government patterns (English, Hindi, Marathi, State/National authorities)
  static final RegExp _governmentRegex = RegExp(
    r'(?:\b(?:aadhaar|uidai|cowin|income\s*tax|itr|pan\s*card|digilocker|voter\s*id|epfo|passbook|challan|e-challan|ministry\s+of|govt\s+of\s+india)\b|आधार|पॅन|मतदार|निवडणूक|शासकीय|सरकारी|महावितरण)',
    caseSensitive: false,
  );

  // Service patterns (Delivery, logistics, bookings, appointments, accounts, Regional)
  static final RegExp _serviceRegex = RegExp(
    r'(?:\b(?:delivered|out\s+for\s+delivery|shipment|dispatched|in\s*transit|track\s+(?:your\s+)?order|order\s+(?:id|number|status|confirmed|placed)|appointment\s+(?:confirmed|scheduled|reminder)|booking\s+(?:confirmed|id)|service\s+request|flight\s+ticket|pnr\s+no|ride\s+arriving|cab\s+booked)\b|वितरित|डिलिव्हरी|डिलीवरी|वितरणासाठी|ऑर्डर|டெலிவரி|డెలివరీ)',
    caseSensitive: false,
  );

  // Promotional patterns (Discounts, sales, vouchers, marketing, Regional)
  static final RegExp _promotionalRegex = RegExp(
    r'(?:\b(?:(?:\d+%\s*off)|flat\s+\d+|discount|cashback|voucher|coupon\s*code|promo\s*code|mega\s*sale|limited\s+(?:time|period)\s+offer|shop\s+now|buy\s+now|exclusive\s+deal|hurry\s+up|avail\s+now|festive\s+offer)\b|सूट|सवलत|ऑफ़र|ऑफर|खरेदी|தள்ளுபடி|తగ్గింపు|ছাড়)',
    caseSensitive: false,
  );

  /// Classifies message body using conservative heuristics.
  ClassificationResult? classify(
    String body,
    ParsedHeader header, {
    String? brand,
    String? detectedOtp,
    PaymentResult payment = const PaymentResult.none(),
    OtpResult? otp,
  }) {
    final lower = body.toLowerCase();
    final resolvedOtp =
        otp ??
        (detectedOtp != null
            ? OtpResult(
                hasOtp: true,
                otpValue: detectedOtp,
                source: OtpSource.otpPattern,
              )
            : const OtpResult.none());

    // 1. Government (high priority keyword match)
    if (_governmentRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.government,
        categorySource: CategorySource.contentPattern,
        confidence: 0.85,
        reason: ClassificationReason.contentRule,
        reasonDescription: 'Government content keyword pattern',
        parsedHeader: header,
        brand: brand,
        payment: payment,
        otp: resolvedOtp,
      );
    }

    // 2. Transactional (financial alerts)
    if (_transactionalRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.transactional,
        categorySource: CategorySource.contentPattern,
        confidence: 0.80,
        reason: ClassificationReason.contentRule,
        reasonDescription: 'Transactional content keyword pattern',
        parsedHeader: header,
        brand: brand,
        payment: payment,
        otp: resolvedOtp,
      );
    }

    // 3. Service (deliveries, bookings, appointments)
    if (_serviceRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.service,
        categorySource: CategorySource.contentPattern,
        confidence: 0.75,
        reason: ClassificationReason.contentRule,
        reasonDescription: 'Service content keyword pattern',
        parsedHeader: header,
        brand: brand,
        payment: payment,
        otp: resolvedOtp,
      );
    }

    // 4. Promotional (marketing, sales)
    if (_promotionalRegex.hasMatch(lower)) {
      return ClassificationResult(
        category: CategoryType.promotional,
        categorySource: CategorySource.contentPattern,
        confidence: 0.75,
        reason: ClassificationReason.contentRule,
        reasonDescription: 'Promotional content keyword pattern',
        parsedHeader: header,
        brand: brand,
        payment: payment,
        otp: resolvedOtp,
      );
    }

    // If only OTP is present without financial context, consider it service (login verification)
    if (resolvedOtp.hasOtp &&
        (lower.contains('verification') ||
            lower.contains('otp') ||
            lower.contains('login') ||
            lower.contains('code'))) {
      return ClassificationResult(
        category: CategoryType.service,
        categorySource: CategorySource.contentPattern,
        confidence: 0.70,
        reason: ClassificationReason.contentRule,
        reasonDescription: 'Service verification/OTP pattern',
        parsedHeader: header,
        brand: brand,
        payment: payment,
        otp: resolvedOtp,
      );
    }

    return null;
  }
}
