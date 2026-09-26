import 'dart:math';
import 'package:delmess/features/classification/domain/otp_result.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';

/// Dedicated local OTP classifier and extractor with false-positive protection.
///
/// NOTE: For security and privacy, extracted OTPs must NEVER be logged,
/// exported to analytics, or transmitted across the network.
class OTPClassifier {
  const OTPClassifier();

  // Keyword triggering OTP analysis (supporting English, Hindi, and Marathi)
  static final RegExp _otpKeywordRegex = RegExp(
    r'(?:\b(?:otp|one[- ]time\s+password|verification\s+code|authentication\s+code|security\s+code|login\s+code|passcode)\b|ओटीपी|वन[- ]टाइम पासवर्ड|पासकोड)',
    caseSensitive: false,
  );

  // Pattern matching numeric codes (4, 5, 6, 8 digits)
  static final RegExp _numericCandidateRegex = RegExp(r'\b([0-9]{4,8})\b');

  // False positive indicators in prefix
  static final RegExp _currencyPrefix = RegExp(r'(?:₹|rs\.?|inr|\$)\s*$');
  static final RegExp _accountPrefix = RegExp(
    r'(?:a/c|account|ending(?:\s+with|\s+in)?|card)\s*$',
  );
  static final RegExp _orderPrefix = RegExp(
    r'(?:order(?:\s*(?:no\.?|id|#))?|invoice|ref(?:\s*(?:no\.?|id))?|ticket|pnr|tracking(?:\s*(?:no\.?|id))?|shipment(?:\s*(?:no\.?|id))?)\s*$',
  );
  static final RegExp _datePrefix = RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\s*$');

  // False positive indicators in suffix
  static final RegExp _currencySuffix = RegExp(r'^\s*(?:/-|rs\.?|inr)');

  /// Performs full OTP classification returning a structured [OtpResult].
  OtpResult classify(String body) {
    final otp = extractOtp(body);
    if (otp != null) {
      return OtpResult(
        hasOtp: true,
        otpValue: otp,
        source: OtpSource.otpPattern,
      );
    }
    return const OtpResult.none();
  }

  /// Extracts OTP from SMS text body if confidently recognized.
  ///
  /// Returns the extracted numeric string (4, 5, 6, or 8 digits) or `null`.
  String? extractOtp(String body) {
    // 1. Guard: If no OTP keywords exist, quickly return null without evaluating candidates
    final keywordMatches = _otpKeywordRegex.allMatches(body).toList();
    if (keywordMatches.isEmpty) {
      return null;
    }

    // 2. Find all 4-8 digit numeric candidates
    final candidateMatches = _numericCandidateRegex.allMatches(body).toList();
    if (candidateMatches.isEmpty) {
      return null;
    }

    String? bestCandidate;
    int shortestDistance = 999999;

    for (final candidate in candidateMatches) {
      final code = candidate.group(1);
      if (code == null) continue;

      // Supported lengths: 4, 5, 6, 8 digits
      final len = code.length;
      if (len != 4 && len != 5 && len != 6 && len != 8) {
        continue;
      }

      final matchStart = candidate.start;
      final matchEnd = candidate.end;

      if (!_isValidOtpCandidate(body, matchStart, matchEnd, code)) {
        continue;
      }

      // Check distance to the closest OTP keyword
      int minDistanceToKeyword = 999999;
      for (final kw in keywordMatches) {
        final int dist;
        if (matchStart >= kw.end) {
          dist = matchStart - kw.end; // Keyword before code
        } else if (matchEnd <= kw.start) {
          dist = kw.start - matchEnd; // Code before keyword
        } else {
          dist = 0;
        }
        minDistanceToKeyword = min(minDistanceToKeyword, dist);
      }

      // Bounded scanning: Candidate must be within 70 characters of an OTP keyword
      if (minDistanceToKeyword <= 70 && minDistanceToKeyword < shortestDistance) {
        shortestDistance = minDistanceToKeyword;
        bestCandidate = code;
      }
    }

    return bestCandidate;
  }

  /// Verifies context does not resemble false-positives (currency, account, order, date).
  bool _isValidOtpCandidate(
    String body,
    int matchStart,
    int matchEnd,
    String code,
  ) {
    // Check pre-context up to 25 characters before match
    final preContextStart = (matchStart - 25).clamp(0, matchStart);
    final preContext = body
        .substring(preContextStart, matchStart)
        .toLowerCase()
        .trim();

    // Check false-positive prefixes
    if (_currencyPrefix.hasMatch(preContext)) return false;
    if (_accountPrefix.hasMatch(preContext)) return false;
    if (_orderPrefix.hasMatch(preContext)) return false;
    if (_datePrefix.hasMatch(preContext)) return false;

    // Check post-context up to 10 characters after match
    final postContextEnd = (matchEnd + 10).clamp(matchEnd, body.length);
    final postContext = body
        .substring(matchEnd, postContextEnd)
        .toLowerCase()
        .trim();

    if (_currencySuffix.hasMatch(postContext)) return false;

    return true;
  }
}
