/// Classification reasons supporting future classifier algorithms.
enum ClassificationReason {
  officialSuffix,
  knownHeader,
  contentRule,
  unknown;

  String get displayName {
    switch (this) {
      case ClassificationReason.officialSuffix:
        return 'Official Suffix (-T/-S/-P/-G)';
      case ClassificationReason.knownHeader:
        return 'Known Sender Header';
      case ClassificationReason.contentRule:
        return 'Content Keyword Rule';
      case ClassificationReason.unknown:
        return 'Unknown / Default';
    }
  }

  static ClassificationReason fromString(String? value) {
    if (value == null) return ClassificationReason.unknown;
    final lower = value.toLowerCase();
    for (final r in ClassificationReason.values) {
      if (r.name.toLowerCase() == lower) return r;
    }
    if (lower.contains('suffix') || lower.contains('explicit -')) {
      return ClassificationReason.officialSuffix;
    }
    if (lower.contains('header') || lower.contains('brand')) {
      return ClassificationReason.knownHeader;
    }
    if (lower.contains('content') ||
        lower.contains('keyword') ||
        lower.contains('rule')) {
      return ClassificationReason.contentRule;
    }
    return ClassificationReason.unknown;
  }
}
