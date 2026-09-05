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
  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

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
