/// Dedicated local OTP classifier and extractor with false-positive protection.
///
/// NOTE: For security and privacy, extracted OTPs must NEVER be logged,
/// exported to analytics, or transmitted across the network.
class OTPClassifier {
  const OTPClassifier();

  // Keyword triggering OTP analysis
  static final RegExp _otpKeywordRegex = RegExp(
    r'\b(?:otp|one[- ]time\s+password|verification\s+code|authentication\s+code|security\s+code|login\s+code|passcode)\b',
    caseSensitive: false,
  );

  // Pattern 1: Keyword followed within 0-45 non-digit chars by numeric code
  // e.g. "Your OTP is 482921", "verification code: 123456", "OTP for transaction authorization is 948215"
  static final RegExp _keywordThenCode = RegExp(
    r'(?:otp|one[- ]time\s+password|verification\s+code|authentication\s+code|security\s+code|login\s+code|passcode)[^\d\n\r]{0,45}?\b([0-9]{4,8})\b',
    caseSensitive: false,
  );

  // Pattern 2: Code followed within 0-45 non-digit chars by keyword
  // e.g. "Use 839201 as your authentication code", "482921 is your OTP"
  static final RegExp _codeThenKeyword = RegExp(
    r'\b([0-9]{4,8})\b[^\d\n\r]{0,45}?(?:otp|one[- ]time\s+password|verification\s+code|authentication\s+code|security\s+code|login\s+code|passcode)\b',
    caseSensitive: false,
  );

  // False positive indicators surrounding a number
  static final RegExp _currencyPrefix = RegExp(r'(?:₹|rs\.?|inr|\$)\s*$');
  static final RegExp _accountPrefix = RegExp(
    r'(?:a/c|account|ending(?:\s+with|\s+in)?|card)\s*$',
  );
  static final RegExp _orderPrefix = RegExp(
    r'(?:order(?:\s*(?:no\.?|id|#))?|invoice|ref(?:\s*(?:no\.?|id))?|ticket)\s*$',
  );

  /// Extracts OTP from SMS text body if confidently recognized.
  ///
  /// Returns the extracted numeric string (4, 5, 6, or 8 digits) or `null`.
  String? extractOtp(String body) {
    // 1. Guard: If no OTP keywords exist, quickly return null without evaluating regex
    if (!_otpKeywordRegex.hasMatch(body)) {
      return null;
    }

    // 2. Try Pattern 1: Keyword then Code
    final matches1 = _keywordThenCode.allMatches(body);
    for (final match in matches1) {
      final code = match.group(1);
      final matchStart = match.end - (code?.length ?? 0);
      if (_isValidOtpCandidate(body, matchStart, match.end, code)) {
        return code;
      }
    }

    // 3. Try Pattern 2: Code then Keyword
    final matches2 = _codeThenKeyword.allMatches(body);
    for (final match in matches2) {
      final code = match.group(1);
      final matchStart = match.start;
      final matchEnd = match.start + (code?.length ?? 0);
      if (_isValidOtpCandidate(body, matchStart, matchEnd, code)) {
        return code;
      }
    }

    return null;
  }

  /// Verifies candidate code length and validates context does not resemble false-positives.
  bool _isValidOtpCandidate(
    String body,
    int matchStart,
    int matchEnd,
    String? code,
  ) {
    if (code == null) return false;

    // Supported lengths: 4, 5, 6, 8 digits
    final len = code.length;
    if (len != 4 && len != 5 && len != 6 && len != 8) {
      return false;
    }

    // Check pre-context up to 20 characters before match
    final preContextStart = (matchStart - 20).clamp(0, matchStart);
    final preContext = body
        .substring(preContextStart, matchStart)
        .toLowerCase()
        .trim();

    // Check false-positive prefixes
    if (_currencyPrefix.hasMatch(preContext)) return false;
    if (_accountPrefix.hasMatch(preContext)) return false;
    if (_orderPrefix.hasMatch(preContext)) return false;

    return true;
  }
}
