/// Structured representation of a parsed Indian SMS sender / header.
class ParsedHeader {
  /// The exact original sender string as delivered by the SMS provider.
  final String rawSender;

  /// Trimmed and uppercase representation for comparison purposes.
  final String normalizedSender;

  /// Two-letter telecom service access provider & circle code (e.g., "AD", "VM", "JD").
  final String? operatorPrefix;

  /// Clean principal entity header (e.g., "HDFCBK", "AMAZON", "SWIGGY").
  final String cleanHeader;

  /// Single-character official TRAI message type suffix:
  /// 'T' (Transactional), 'S' (Service), 'P' (Promotional), 'G' (Government).
  final String? suffix;

  /// Indicates whether the sender matches commercial alphanumeric header conventions.
  final bool isCommercial;

  const ParsedHeader({
    required this.rawSender,
    required this.normalizedSender,
    this.operatorPrefix,
    required this.cleanHeader,
    this.suffix,
    this.isCommercial = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedHeader &&
          runtimeType == other.runtimeType &&
          rawSender == other.rawSender &&
          operatorPrefix == other.operatorPrefix &&
          cleanHeader == other.cleanHeader &&
          suffix == other.suffix &&
          isCommercial == other.isCommercial;

  @override
  int get hashCode =>
      rawSender.hashCode ^
      operatorPrefix.hashCode ^
      cleanHeader.hashCode ^
      suffix.hashCode ^
      isCommercial.hashCode;

  @override
  String toString() =>
      'ParsedHeader(raw: $rawSender, prefix: $operatorPrefix, header: $cleanHeader, suffix: $suffix, commercial: $isCommercial)';
}
