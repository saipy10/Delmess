import 'package:delmess/features/classification/domain/parsed_header.dart';

/// Robust parser for Indian commercial SMS sender headers complying with
/// TRAI (Telecom Regulatory Authority of India) conventions.
///
/// Handles all real-world Android carrier quirks:
/// - Explicit suffixes: `-P` (Promotional), `-S` (Service), `-T` (Transactional), `-G` (Government)
/// - Format: `[OperatorPrefix]-[Header]-[Suffix]` (e.g., `AX-HDFCBN-P`, `AD-HDFCBN-T`, `JD-SWIGGY-S`, `XX-GOVT-G`)
/// - Lowercase/uppercase variations (`ax-hdfcbn-p`, `ad-hdfcbn-t`)
/// - Whitespace & padding (`  AX-HDFCBN-P  `, `AX - HDFCBN - P`)
/// - Carrier prepends (`+91AX-HDFCBN-P`, `+91-AD-HDFCBN-T`, `91-AX-HDFCBN-P`, `0-AD-HDFCBN-T`)
/// - Non-hyphen delimiters (`AX_HDFCBN_P`, `AX/HDFCBN/P`, `AX.HDFCBN.P`, `AX:HDFCBN:P`)
/// - Header without prefix (`HDFCBN-P`, `SWIGGY-S`)
/// - Bare alphanumeric headers (`AMAZON`, `SWIGGY`, `HDFCBN`)
/// - Personal phone numbers (`+919876543210`, `9876543210`) safely flagged as non-commercial
/// - Short codes and malformed senders
class SmsHeaderParser {
  const SmsHeaderParser();

  /// Official TRAI single-character message type suffixes:
  /// P = Promotional
  /// S = Service
  /// T = Transactional
  /// G = Government
  static const Set<String> validSuffixes = {'P', 'S', 'T', 'G'};

  /// Regular expression for detecting standard phone numbers (+91..., 10-15 digits).
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  /// Regular expression for 2-letter operator/circle prefix.
  static final RegExp _operatorPrefixRegex = RegExp(r'^[A-Z]{2}$');

  /// Regular expression for alphanumeric entity code (typically 3-11 characters).
  static final RegExp _headerCodeRegex = RegExp(r'^[A-Z0-9]{3,11}$');

  /// Regex for stripping international/carrier phone code prefix prepended to commercial headers.
  /// E.g. "+91-AX-HDFCBN-P" -> "AX-HDFCBN-P", "+91AX-HDFCBN-P" -> "AX-HDFCBN-P"
  static final RegExp _carrierPrependRegex = RegExp(
    r'^(?:\+?91[\s\-_/:]?|0[\s\-_/:]?)(?=[A-Za-z]{2}[\s\-_/:]?[A-Za-z0-9])',
    caseSensitive: false,
  );

  /// Delimiter pattern matching hyphen, underscore, slash, dot, colon, or whitespace.
  static final RegExp _delimiterRegex = RegExp(r'[\s\-_/:.]+');

  /// Parses an SMS sender string into a structured [ParsedHeader].
  ///
  /// Always preserves [rawSender] exactly without mutation.
  ParsedHeader parse(String rawSender) {
    // 1. Basic sanitize of invisible characters & trim
    final sanitized = rawSender
        .replaceAll(RegExp(r'[\u00A0\u200B\u200C\u200D\uFEFF]'), ' ')
        .trim();

    if (sanitized.isEmpty) {
      return ParsedHeader(
        rawSender: rawSender,
        normalizedSender: '',
        cleanHeader: 'UNKNOWN',
        isCommercial: false,
      );
    }

    final upper = sanitized.toUpperCase();

    // 2. Check if it's a mobile phone number (not a commercial header)
    final digitsOnly = upper.replaceAll(RegExp(r'[\s\-]'), '');
    if (_phoneRegex.hasMatch(digitsOnly)) {
      return ParsedHeader(
        rawSender: rawSender,
        normalizedSender: upper,
        cleanHeader: digitsOnly.startsWith('+91')
            ? digitsOnly.substring(3)
            : (digitsOnly.startsWith('91') && digitsOnly.length > 10
                  ? digitsOnly.substring(2)
                  : digitsOnly),
        isCommercial: false,
      );
    }

    // 3. Strip carrier prefix if attached to a commercial header
    var workingSender = upper;
    if (_carrierPrependRegex.hasMatch(workingSender)) {
      workingSender = workingSender.replaceFirst(_carrierPrependRegex, '');
    }

    // 4. Split into candidate tokens by delimiters
    final tokens = workingSender
        .split(_delimiterRegex)
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return ParsedHeader(
        rawSender: rawSender,
        normalizedSender: upper,
        cleanHeader: 'UNKNOWN',
        isCommercial: false,
      );
    }

    // 5. Check if isolated malformed suffix, e.g. "-T", "-P", "P"
    if (tokens.length == 1 && validSuffixes.contains(tokens.first)) {
      return ParsedHeader(
        rawSender: rawSender,
        normalizedSender: upper,
        cleanHeader: tokens.first,
        suffix: null,
        isCommercial: false,
      );
    }

    // 6. Check if the last token is an explicit TRAI suffix
    final lastToken = tokens.last;
    final hasSuffix =
        tokens.length >= 2 &&
        lastToken.length == 1 &&
        validSuffixes.contains(lastToken);

    if (hasSuffix) {
      final suffix = lastToken;
      final remainingTokens = tokens.sublist(0, tokens.length - 1);

      if (remainingTokens.length >= 2) {
        // Format: [Prefix] - [Header(s)] - [Suffix]
        // E.g. "AX-HDFCBN-P", "AD-HDFCBN-T", "VM-AMAZON-P", "AX-HDFC-BN-P"
        final firstToken = remainingTokens.first;
        if (_operatorPrefixRegex.hasMatch(firstToken)) {
          final prefix = firstToken;
          final headerParts = remainingTokens.sublist(1).join('');
          final cleanHeader = headerParts.replaceAll(RegExp(r'[^A-Z0-9]'), '');

          if (cleanHeader.isNotEmpty) {
            return ParsedHeader(
              rawSender: rawSender,
              normalizedSender: '$prefix-$cleanHeader-$suffix',
              operatorPrefix: prefix,
              cleanHeader: cleanHeader,
              suffix: suffix,
              isCommercial: true,
            );
          }
        }
      }

      if (remainingTokens.length == 1) {
        // Format: [Header] - [Suffix] (no operator prefix)
        // E.g. "HDFCBN-P", "HDFCBN-T", "AMAZON-P", "SWIGGY-S"
        final headerCandidate = remainingTokens.first.replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
        if (_headerCodeRegex.hasMatch(headerCandidate)) {
          return ParsedHeader(
            rawSender: rawSender,
            normalizedSender: '$headerCandidate-$suffix',
            operatorPrefix: null,
            cleanHeader: headerCandidate,
            suffix: suffix,
            isCommercial: true,
          );
        }
      }

      // If multiple tokens exist before suffix, join middle tokens as header
      final headerJoined = remainingTokens.join('');
      if (_headerCodeRegex.hasMatch(headerJoined)) {
        return ParsedHeader(
          rawSender: rawSender,
          normalizedSender: '$headerJoined-$suffix',
          operatorPrefix: null,
          cleanHeader: headerJoined,
          suffix: suffix,
          isCommercial: true,
        );
      }
    }

    // 7. No suffix: Check for 2 parts without suffix
    if (tokens.length == 2) {
      final part1 = tokens[0];
      final part2 = tokens[1];

      // Format: [Prefix] - [Header], e.g. "AD-HDFCBN", "JD-SWIGGY", "VM-AMAZON"
      if (_operatorPrefixRegex.hasMatch(part1) &&
          _headerCodeRegex.hasMatch(part2)) {
        return ParsedHeader(
          rawSender: rawSender,
          normalizedSender: '$part1-$part2',
          operatorPrefix: part1,
          cleanHeader: part2,
          suffix: null,
          isCommercial: true,
        );
      }
    }

    // 7b. Format with 3 or more tokens where last token was not a valid suffix:
    // e.g. "AD-HDFCBK-X" -> prefix: "AD", cleanHeader: "HDFCBK", suffix: null
    if (tokens.length >= 3) {
      final first = tokens[0];
      final middle = tokens[1];
      if (_operatorPrefixRegex.hasMatch(first) &&
          _headerCodeRegex.hasMatch(middle)) {
        return ParsedHeader(
          rawSender: rawSender,
          normalizedSender: '$first-$middle-${tokens.sublist(2).join('')}',
          operatorPrefix: first,
          cleanHeader: middle,
          suffix: null,
          isCommercial: false,
        );
      }
    }

    // 8. Format: Bare alphanumeric header, e.g. "AMAZON", "SWIGGY", "HDFCBN", "FLPKRT"
    final cleanAlphanumeric = workingSender.replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    if (_headerCodeRegex.hasMatch(cleanAlphanumeric) &&
        !RegExp(r'^[0-9]+$').hasMatch(cleanAlphanumeric)) {
      return ParsedHeader(
        rawSender: rawSender,
        normalizedSender: cleanAlphanumeric,
        operatorPrefix: null,
        cleanHeader: cleanAlphanumeric,
        suffix: null,
        isCommercial: true,
      );
    }

    // 9. Numeric short code, e.g. 56161
    if (RegExp(r'^[0-9]{4,8}$').hasMatch(cleanAlphanumeric)) {
      return ParsedHeader(
        rawSender: rawSender,
        normalizedSender: cleanAlphanumeric,
        cleanHeader: cleanAlphanumeric,
        suffix: null,
        isCommercial: false,
      );
    }

    // 10. Fallback for unclassified / non-standard sender
    return ParsedHeader(
      rawSender: rawSender,
      normalizedSender: upper,
      cleanHeader: cleanAlphanumeric.isNotEmpty ? cleanAlphanumeric : upper,
      suffix: null,
      isCommercial: false,
    );
  }
}
