import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';

/// Information about a resolved brand (retained for model compatibility).
class BrandInfo {
  final String brandName;
  final String? organization;
  final String? industry;
  final CategoryType? defaultCategory;

  const BrandInfo({
    required this.brandName,
    this.organization,
    this.industry,
    this.defaultCategory,
  });
}

/// Resolves Indian SMS entity headers without mapping to arbitrary brand names.
/// Headers are preserved as authentic sender identifiers (e.g. HDFCBK, SWIGGY).
class BrandResolver {
  final SenderMetadataRepository? repository;
  final Map<String, BrandInfo> _cache = {};

  BrandResolver({this.repository});

  /// Synchronously looks up brand info for [cleanHeader].
  /// Note: Built-in mapping of headers to friendly brand names is disabled.
  BrandInfo? resolveSync(String cleanHeader) {
    final key = cleanHeader.toUpperCase().trim();
    return _cache[key];
  }

  /// Asynchronously looks up brand info with database backing.
  Future<BrandInfo?> resolve(String cleanHeader) async {
    final key = cleanHeader.toUpperCase().trim();
    if (_cache.containsKey(key)) {
      return _cache[key];
    }
    return null;
  }

  /// Preloads or updates a brand in the resolver cache.
  void cacheBrand(String header, BrandInfo info) {
    _cache[header.toUpperCase().trim()] = info;
  }

  /// Resolves display name by returning the authentic header or raw sender.
  /// Never maps headers to artificial company names (e.g. HDFCBK remains HDFCBK).
  String getDisplayName(String cleanHeader, {String? rawSender}) {
    if (cleanHeader.isNotEmpty && cleanHeader != 'UNKNOWN') {
      return cleanHeader;
    }
    return rawSender ?? 'Unknown';
  }
}
