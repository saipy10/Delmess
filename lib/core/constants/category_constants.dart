import 'package:delmess/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Metadata definition for categories used throughout the application.
enum CategoryType {
  transactional,
  service,
  promotional,
  government,
  other;

  String get displayName {
    switch (this) {
      case CategoryType.transactional:
        return 'Transactional';
      case CategoryType.service:
        return 'Service';
      case CategoryType.promotional:
        return 'Promotional';
      case CategoryType.government:
        return 'Government';
      case CategoryType.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case CategoryType.transactional:
        return 'Bank alerts, UPI transfers, credit card updates & bills';
      case CategoryType.service:
        return 'Delivery trackers, OTPs, booking confirmations & utilities';
      case CategoryType.promotional:
        return 'Discounts, sales, vouchers & brand offers';
      case CategoryType.government:
        return 'Aadhaar, CoWIN, Income Tax, Traffic alerts & DigiLocker';
      case CategoryType.other:
        return 'Personal conversations & unclassified messages';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.transactional:
        return Icons.account_balance_wallet_outlined;
      case CategoryType.service:
        return Icons.local_shipping_outlined;
      case CategoryType.promotional:
        return Icons.local_offer_outlined;
      case CategoryType.government:
        return Icons.account_balance_outlined;
      case CategoryType.other:
        return Icons.chat_bubble_outline;
    }
  }

  IconData get filledIcon {
    switch (this) {
      case CategoryType.transactional:
        return Icons.account_balance_wallet;
      case CategoryType.service:
        return Icons.local_shipping;
      case CategoryType.promotional:
        return Icons.local_offer;
      case CategoryType.government:
        return Icons.account_balance;
      case CategoryType.other:
        return Icons.chat_bubble;
    }
  }

  Color getColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (this) {
      case CategoryType.transactional:
        return isDark
            ? AppColors.catTransactionalDark
            : AppColors.catTransactionalLight;
      case CategoryType.service:
        return isDark ? AppColors.catServiceDark : AppColors.catServiceLight;
      case CategoryType.promotional:
        return isDark
            ? AppColors.catPromotionalDark
            : AppColors.catPromotionalLight;
      case CategoryType.government:
        return isDark
            ? AppColors.catGovernmentDark
            : AppColors.catGovernmentLight;
      case CategoryType.other:
        return isDark ? AppColors.catOtherDark : AppColors.catOtherLight;
    }
  }

  Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (this) {
      case CategoryType.transactional:
        return isDark
            ? AppColors.catTransactionalBgDark
            : AppColors.catTransactionalBgLight;
      case CategoryType.service:
        return isDark
            ? AppColors.catServiceBgDark
            : AppColors.catServiceBgLight;
      case CategoryType.promotional:
        return isDark
            ? AppColors.catPromotionalBgDark
            : AppColors.catPromotionalBgLight;
      case CategoryType.government:
        return isDark
            ? AppColors.catGovernmentBgDark
            : AppColors.catGovernmentBgLight;
      case CategoryType.other:
        return isDark ? AppColors.catOtherBgDark : AppColors.catOtherBgLight;
    }
  }
}
