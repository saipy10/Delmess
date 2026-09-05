import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/classification/domain/classification_result.dart';
import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sender_metadata.dart';

/// Classifies messages by recognizing known Indian commercial sender headers
/// from the existing [SenderMetadataRepository].
class KnownHeaderClassifier {
  final SenderMetadataRepository? repository;

  // In-memory cache for high-throughput batch imports (e.g. 10,000+ messages)
  final Map<String, SenderMetadata?> _cache = {};

  KnownHeaderClassifier({this.repository});

  /// Clears the in-memory sender metadata cache.
  void clearCache() {
    _cache.clear();
  }

  /// Adds or preloads a sender metadata record in the cache.
  void cacheMetadata(SenderMetadata meta) {
    _cache[meta.header.toUpperCase().trim()] = meta;
  }

  /// Looks up brand and metadata for a given [cleanHeader].
  Future<SenderMetadata?> lookupMetadata(String cleanHeader) async {
    final key = cleanHeader.toUpperCase().trim();
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    if (repository != null) {
      try {
        final meta = await repository!.getMetadataForHeader(key);
        _cache[key] = meta;
        return meta;
      } catch (_) {
        // Safe database lookup fallback
      }
    }

    return null;
  }

  /// Synchronous cache-only lookup.
  SenderMetadata? lookupCached(String cleanHeader) {
    final key = cleanHeader.toUpperCase().trim();
    return _cache[key];
  }

  /// Classifies a message from known sender metadata if no official suffix determined category.
  ClassificationResult? classifyWithMetadata(
    ParsedHeader header,
    SenderMetadata? metadata, {
    String? detectedOtp,
  }) {
    if (metadata == null) return null;

    final industry = metadata.industry.toLowerCase();
    CategoryType? category;

    if (industry.contains('bank') ||
        industry.contains('financ') ||
        industry.contains('credit') ||
        industry.contains('loan')) {
      category = CategoryType.transactional;
    } else if (industry.contains('govt') ||
        industry.contains('government') ||
        industry.contains('tax') ||
        industry.contains('aadhaar') ||
        industry.contains('ministry')) {
      category = CategoryType.government;
    } else if (industry.contains('delivery') ||
        industry.contains('food') ||
        industry.contains('commerce') ||
        industry.contains('utility') ||
        industry.contains('travel') ||
        industry.contains('ride')) {
      category = CategoryType.service;
    }

    if (category == null) return null;

    return ClassificationResult(
      category: category,
      confidence: 0.90,
      reason: ClassificationReason.knownHeader,
      parsedHeader: header,
      brand: metadata.brand,
      detectedOtp: detectedOtp,
    );
  }
}
