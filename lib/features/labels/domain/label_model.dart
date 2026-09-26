import 'package:flutter/material.dart';

/// User-defined or system-managed custom label/tag.
class LabelModel {
  final String id;
  final String name;
  final int colorValue;
  final int iconCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  const LabelModel({
    required this.id,
    required this.name,
    this.colorValue = 0xFF6750A4, // Default primary purple
    this.iconCode = 0xe362, // Icons.label_outline codePoint
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
  });

  Color get color => Color(colorValue);

  static const Map<int, IconData> _iconMap = {
    0xe362: Icons.label_outline,
    0xe363: Icons.label,
    0xe040: Icons.account_balance,
    0xf33c: Icons.security,
    0xe395: Icons.local_shipping,
    0xe3a1: Icons.local_offer,
    0xe5f8: Icons.star,
    0xe5f9: Icons.star,
    0xe5fa: Icons.star_border,
    0xe69f: Icons.work,
    0xe8cc: Icons.shopping_bag,
    0xe8f6: Icons.receipt_long,
    0xe897: Icons.lock,
    0xe3ab: Icons.mail,
    0xe873: Icons.description,
    0xe8b8: Icons.settings,
    0xe5cd: Icons.favorite,
    0xe85d: Icons.bookmark,
    0xe52e: Icons.flight,
    0xe530: Icons.directions_car,
    0xe532: Icons.train,
    0xe556: Icons.restaurant,
    0xe54c: Icons.medical_services,
    0xe32a: Icons.home,
    0xe0b0: Icons.call,
    0xe0e1: Icons.credit_card,
    0xe227: Icons.payment,
  };

  IconData get icon => _iconMap[iconCode] ?? Icons.label_outline;

  LabelModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
  }) {
    return LabelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorValue == other.colorValue &&
          iconCode == other.iconCode &&
          messageCount == other.messageCount;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      colorValue.hashCode ^
      iconCode.hashCode ^
      messageCount.hashCode;
}
