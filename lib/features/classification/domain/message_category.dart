import 'package:delmess/core/constants/category_constants.dart';
import 'package:flutter/material.dart';

export 'package:delmess/core/constants/category_constants.dart'
    show CategoryType;

/// Helper extensions and metadata mapping for MessageCategory.
extension CategoryTypeExtension on CategoryType {
  String get id => name;

  static CategoryType fromString(String? value) {
    if (value == null) return CategoryType.other;
    return CategoryType.values.firstWhere(
      (c) =>
          c.name.toLowerCase() == value.toLowerCase() ||
          c.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => CategoryType.other,
    );
  }
}

/// Metadata model for presenting Category summaries and statistics.
class CategoryMeta {
  final CategoryType category;
  final int unreadCount;
  final int totalCount;
  final String? lastActivity;

  const CategoryMeta({
    required this.category,
    this.unreadCount = 0,
    this.totalCount = 0,
    this.lastActivity,
  });

  String get title => category.displayName;
  String get description => category.description;
  IconData get icon => category.icon;
}
