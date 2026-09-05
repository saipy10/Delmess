/// String manipulation and extraction utilities for SMS processing.
class StringUtils {
  StringUtils._();

  /// Regex patterns to extract 4 to 8 digit OTPs / verification codes.
  static final RegExp _otpPrefixRegex = RegExp(
    r'(?:otp|verification\s+code|code|pin|secret|passcode|one[\s\-]time\s+password)[\s\:\-\=]+(?:is\s+)?([0-9]{4,8})\b',
    caseSensitive: false,
  );

  static final RegExp _otpContextRegex = RegExp(
    r'(?:your|the)\s+(?:login\s+|transaction\s+)?(?:otp|verification\s+code|code)[\s\w\.\,\/]*?\bis\s+([0-9]{4,8})\b',
    caseSensitive: false,
  );

  static final RegExp _otpSuffixRegex = RegExp(
    r'\b([0-9]{4,8})\s+(?:is\s+your|is\s+the|is)\s+(?:otp|verification|code|one[\s\-]time)',
    caseSensitive: false,
  );

  static final RegExp _useCodeRegex = RegExp(
    r'(?:use|enter)\s+(?:code|otp)\s+([0-9]{4,8})\b',
    caseSensitive: false,
  );

  static final RegExp _fallbackDigitsRegex = RegExp(r'\b([0-9]{4,8})\b');

  /// Attempts to extract an OTP from an SMS body string.
  static String? extractOtp(String body) {
    if (body.trim().isEmpty) return null;

    // Try targeted prefix pattern: e.g. "OTP: 482913", "OTP is 482913"
    final prefixMatch = _otpPrefixRegex.firstMatch(body);
    if (prefixMatch != null && prefixMatch.group(1) != null) {
      return prefixMatch.group(1);
    }

    // Try contextual pattern: e.g. "Your OTP for transaction at Amazon is 482921"
    final contextMatch = _otpContextRegex.firstMatch(body);
    if (contextMatch != null && contextMatch.group(1) != null) {
      return contextMatch.group(1);
    }

    // Try suffix pattern: e.g. "482913 is your OTP"
    final suffixMatch = _otpSuffixRegex.firstMatch(body);
    if (suffixMatch != null && suffixMatch.group(1) != null) {
      return suffixMatch.group(1);
    }

    // Try action pattern: e.g. "Use code 482913 to verify"
    final useCodeMatch = _useCodeRegex.firstMatch(body);
    if (useCodeMatch != null && useCodeMatch.group(1) != null) {
      return useCodeMatch.group(1);
    }

    // Fallback: If text contains OTP keywords, inspect digit matches
    final lower = body.toLowerCase();
    if (lower.contains('otp') ||
        lower.contains('verification') ||
        lower.contains('one-time password') ||
        lower.contains('passcode')) {
      final matches = _fallbackDigitsRegex.allMatches(body);
      for (final m in matches) {
        final candidate = m.group(1)!;
        final start = m.start;
        final end = m.end;

        // Check context around candidate to reject currency, account masks, or duration
        final prefix = body.substring(start > 15 ? start - 15 : 0, start).toLowerCase();
        final suffix = body.substring(end, end + 15 < body.length ? end + 15 : body.length).toLowerCase();

        // Reject if preceded by currency symbols/words
        if (prefix.contains('rs') ||
            prefix.contains('inr') ||
            prefix.contains('₹') ||
            prefix.contains('\$')) {
          continue;
        }

        // Reject if account mask context (e.g. A/c ending 1234)
        if (prefix.contains('ending') ||
            prefix.contains('a/c') ||
            prefix.contains('account') ||
            prefix.contains('xx') ||
            prefix.contains('card')) {
          continue;
        }

        // Reject if followed by minutes/duration
        if (suffix.startsWith(' min') ||
            suffix.startsWith('min') ||
            suffix.startsWith(' sec') ||
            suffix.startsWith('sec') ||
            suffix.startsWith(' hr') ||
            suffix.startsWith('hr')) {
          continue;
        }

        return candidate;
      }
    }

    return null;
  }

  /// Formats Indian sender codes like 'VK-HDFCBK', 'AD-SWIGGY', 'DZ-SBIINB' into readable display name.
  static String formatSenderName(String sender) {
    if (sender.contains('-')) {
      final parts = sender.split('-');
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        return parts[1].trim();
      }
    }
    return sender;
  }

  /// Generates 1-2 character monogram for sender avatars.
  static String getInitials(String text) {
    final clean = formatSenderName(text).trim();
    if (clean.isEmpty) return '?';
    if (clean.length <= 2) return clean.toUpperCase();
    final words = clean.split(' ');
    if (words.length > 1) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return clean.substring(0, 2).toUpperCase();
  }
}
