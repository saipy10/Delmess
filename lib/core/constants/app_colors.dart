import 'package:flutter/material.dart';

/// App color palette tokens with rich contrast, accessible tones, and modern Material 3 aesthetics.
class AppColors {
  AppColors._();

  // Primary brand palette (Deep Indigo / Electric Violet)
  static const Color primaryLight = Color(0xFF3F51B5);
  static const Color primaryContainerLight = Color(0xFFE8EAF6);
  static const Color primaryDark = Color(0xFF9FA8DA);
  static const Color primaryContainerDark = Color(0xFF283593);

  // Secondary brand palette (Cyan / Slate Teal)
  static const Color secondaryLight = Color(0xFF00838F);
  static const Color secondaryContainerLight = Color(0xFFE0F7FA);
  static const Color secondaryDark = Color(0xFF80DEEA);
  static const Color secondaryContainerDark = Color(0xFF004D40);

  // Surface & Background (Light)
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceVariantLight = Color(0xFFECEFF1);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // Surface & Background (Dark)
  static const Color surfaceDark = Color(0xFF121417);
  static const Color surfaceVariantDark = Color(0xFF1E2228);
  static const Color backgroundDark = Color(0xFF0E1013);
  static const Color cardDark = Color(0xFF181C22);
  static const Color dividerDark = Color(0xFF262C36);

  // Category Accent Colors (Indian SMS Classification)
  // 1. Transactional (Teal / Emerald - Banking & Financial alerts)
  static const Color catTransactionalLight = Color(0xFF00897B);
  static const Color catTransactionalBgLight = Color(0xFFE0F2F1);
  static const Color catTransactionalDark = Color(0xFF4DB6AC);
  static const Color catTransactionalBgDark = Color(0xFF00363A);

  // 2. Service (Amber / Orange - Delivery, Ride, OTP, Utilities)
  static const Color catServiceLight = Color(0xFFE65100);
  static const Color catServiceBgLight = Color(0xFFFFF3E0);
  static const Color catServiceDark = Color(0xFFFFB74D);
  static const Color catServiceBgDark = Color(0xFF4E2600);

  // 3. Promotional (Purple / Berry - Offers, Sales, Discounts)
  static const Color catPromotionalLight = Color(0xFF7B1FA2);
  static const Color catPromotionalBgLight = Color(0xFFF3E5F5);
  static const Color catPromotionalDark = Color(0xFFBA68C8);
  static const Color catPromotionalBgDark = Color(0xFF38006B);

  // 4. Government (Navy / Blue - UIDAI, CoWIN, Income Tax, Challans)
  static const Color catGovernmentLight = Color(0xFF1565C0);
  static const Color catGovernmentBgLight = Color(0xFFE3F2FD);
  static const Color catGovernmentDark = Color(0xFF64B5F6);
  static const Color catGovernmentBgDark = Color(0xFF0D47A1);

  // 5. Other (Slate / Graphite - General communications)
  static const Color catOtherLight = Color(0xFF546E7A);
  static const Color catOtherBgLight = Color(0xFFECEFF1);
  static const Color catOtherDark = Color(0xFFB0BEC5);
  static const Color catOtherBgDark = Color(0xFF263238);

  // Status & Semantic Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);
  static const Color star = Color(0xFFFFB300);
}
