import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabelModel Domain Tests', () {
    final now = DateTime(2026, 9, 1);

    test('creates LabelModel with proper defaults', () {
      final label = LabelModel(
        id: 'lbl_1',
        name: 'Finance',
        createdAt: now,
        updatedAt: now,
      );

      expect(label.id, 'lbl_1');
      expect(label.name, 'Finance');
      expect(label.color, const Color(0xFF6750A4));
      expect(label.icon.fontFamily, 'MaterialIcons');
      expect(label.messageCount, 0);
    });

    test('custom color and icon resolution works', () {
      final label = LabelModel(
        id: 'lbl_2',
        name: 'Urgent',
        colorValue: 0xFFD32F2F,
        iconCode: Icons.star.codePoint,
        createdAt: now,
        updatedAt: now,
        messageCount: 5,
      );

      expect(label.color, const Color(0xFFD32F2F));
      expect(label.icon.codePoint, Icons.star.codePoint);
      expect(label.messageCount, 5);
    });

    test('equality and copyWith work as expected', () {
      final label1 = LabelModel(
        id: 'lbl_1',
        name: 'Shopping',
        createdAt: now,
        updatedAt: now,
      );
      final label2 = LabelModel(
        id: 'lbl_1',
        name: 'Shopping',
        createdAt: now,
        updatedAt: now,
      );

      expect(label1, equals(label2));

      final renamed = label1.copyWith(name: 'E-Commerce');
      expect(renamed.name, 'E-Commerce');
      expect(renamed.id, label1.id);
    });
  });
}
