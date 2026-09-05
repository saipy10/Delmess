import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/core/database/app_database.dart';
import 'package:delmess/features/labels/data/label_repository.dart';
import 'package:delmess/features/messages/data/message_repository.dart';
import 'package:delmess/features/messages/data/sender_metadata_repository.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sender_metadata.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';
import 'package:flutter/foundation.dart';

class DatabaseSeedService {
  final MessageRepository messageRepo;
  final LabelRepository labelRepo;
  final SenderMetadataRepository senderRepo;
  final AppDatabase db;

  DatabaseSeedService({
    required this.messageRepo,
    required this.labelRepo,
    required this.senderRepo,
    required this.db,
  });

  /// Check if the database needs initial seeding
  Future<void> seedIfEmpty() async {
    final messages = await messageRepo.getAllMessages();
    if (messages.isEmpty) {
      debugPrint('Database is empty. Seeding realistic SMS dataset...');
      await resetAndSeed();
    }
  }

  /// Completely clears and reseeds sample development dataset
  Future<void> resetAndSeed() async {
    await db.transaction(() async {
      await db.delete(db.messageLabels).go();
      await db.delete(db.messages).go();
      await db.delete(db.labels).go();
      await db.delete(db.senderMetadataTable).go();
    });

    final now = DateTime.now();

    // 1. Seed Sender Metadata
    final senders = [
      SenderMetadata(
        id: 'meta_hdfc_bn',
        header: 'HDFCBN',
        brand: 'HDFC Bank',
        organization: 'HDFC Bank Ltd.',
        industry: 'Banking & Financial Services',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_hdfc',
        header: 'HDFCBK',
        brand: 'HDFC Bank',
        organization: 'HDFC Bank Ltd.',
        industry: 'Banking & Financial Services',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_sbi',
        header: 'SBIINB',
        brand: 'SBI Bank',
        organization: 'State Bank of India',
        industry: 'Banking',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_amazon',
        header: 'AMAZON',
        brand: 'Amazon India',
        organization: 'Amazon Wholesale India Pvt Ltd',
        industry: 'E-Commerce',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_swiggy',
        header: 'SWIGGY',
        brand: 'Swiggy',
        organization: 'Bundl Technologies Pvt Ltd',
        industry: 'Food & Delivery',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_zomato',
        header: 'ZOMATO',
        brand: 'Zomato',
        organization: 'Zomato Ltd',
        industry: 'Food & Delivery',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_govt',
        header: 'GOVTIN',
        brand: 'Govt of India',
        organization: 'Ministry of Electronics and IT',
        industry: 'Government Services',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_flipkart',
        header: 'FLPKRT',
        brand: 'Flipkart',
        organization: 'Flipkart Internet Pvt Ltd',
        industry: 'E-Commerce',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_amzin',
        header: 'AMZIN',
        brand: 'Amazon India',
        organization: 'Amazon Wholesale India Pvt Ltd',
        industry: 'E-Commerce',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_domino',
        header: 'DOMINO',
        brand: "Domino's Pizza",
        organization: 'Jubilant FoodWorks Ltd',
        industry: 'Food & Delivery',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_actfib',
        header: 'ACTFIB',
        brand: 'ACT Fibernet',
        organization: 'Atria Convergence Technologies',
        industry: 'Utilities & Internet',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_uidai',
        header: 'UIDAI',
        brand: 'UIDAI Aadhaar',
        organization: 'Unique Identification Authority of India',
        industry: 'Government Services',
        updatedAt: now,
      ),
      SenderMetadata(
        id: 'meta_income',
        header: 'INCOME',
        brand: 'Income Tax Department',
        organization: 'Ministry of Finance, Govt of India',
        industry: 'Government Services',
        updatedAt: now,
      ),
    ];
    await senderRepo.upsertAll(senders);

    // 2. Seed Labels
    final labelBanking = await labelRepo.createLabel(
      name: 'Banking',
      colorValue: 0xFF1E88E5, // Blue
      iconCode: 0xe040, // account_balance
    );
    final labelOtp = await labelRepo.createLabel(
      name: 'OTPs',
      colorValue: 0xFFE53935, // Red
      iconCode: 0xf33c, // security
    );
    final labelDeliveries = await labelRepo.createLabel(
      name: 'Deliveries',
      colorValue: 0xFF43A047, // Green
      iconCode: 0xe395, // local_shipping
    );
    final labelOffers = await labelRepo.createLabel(
      name: 'Offers & Deals',
      colorValue: 0xFFFB8C00, // Orange
      iconCode: 0xe3a1, // local_offer
    );
    final labelImportant = await labelRepo.createLabel(
      name: 'Important',
      colorValue: 0xFF8E24AA, // Purple
      iconCode: 0xe5f8, // star
    );

    // 3. Seed Realistic Sample Messages
    final sampleMessages = [
      // Thread 1: HDFC Bank (Transactional with OTP, Pinned, Unread)
      SmsMessage(
        id: 'msg_hdfc_1',
        threadId: 'thread_hdfc',
        sender: 'AD-HDFCBK-T',
        header: 'HDFCBK',
        brand: 'HDFC Bank',
        body:
            'Your OTP for transaction of INR 4,999.00 at AMAZON INDIA is 482921. Valid for 10 minutes. Do not share with anyone.',
        receivedAt: now.subtract(const Duration(minutes: 5)),
        category: CategoryType.transactional,
        classificationConfidence: 0.99,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: false,
        isStarred: true,
        isPinned: true,
        otp: '482921',
        labels: [labelBanking, labelOtp, labelImportant],
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
      SmsMessage(
        id: 'msg_hdfc_2',
        threadId: 'thread_hdfc',
        sender: 'AD-HDFCBK-T',
        header: 'HDFCBK',
        brand: 'HDFC Bank',
        body:
            'A/C XX4921 debited for INR 4,999.00 on 01-Sep-26 via UPI Ref 623910839210. Avail Bal: INR 84,210.50. If not done by you, call 18002583838.',
        receivedAt: now.subtract(const Duration(minutes: 3)),
        category: CategoryType.transactional,
        classificationConfidence: 0.99,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: false,
        isStarred: false,
        isPinned: true,
        labels: [labelBanking, labelImportant],
        createdAt: now.subtract(const Duration(minutes: 3)),
        updatedAt: now.subtract(const Duration(minutes: 3)),
      ),

      // Thread 2: Swiggy (Service delivery notification)
      SmsMessage(
        id: 'msg_swiggy_1',
        threadId: 'thread_swiggy',
        sender: 'JD-SWIGGY-S',
        header: 'SWIGGY',
        brand: 'Swiggy',
        body:
            'Your Biryani Blues order #SWG98210 is on the way! Delivery partner Rajesh is arriving in 12 mins. Track live in app.',
        receivedAt: now.subtract(const Duration(minutes: 25)),
        category: CategoryType.service,
        classificationConfidence: 0.98,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: false,
        isStarred: false,
        isPinned: false,
        labels: [labelDeliveries],
        createdAt: now.subtract(const Duration(minutes: 25)),
        updatedAt: now.subtract(const Duration(minutes: 25)),
      ),

      // Thread 3: Amazon Sale (Promotional)
      SmsMessage(
        id: 'msg_amazon_1',
        threadId: 'thread_amazon',
        sender: 'VM-AMAZON-P',
        header: 'AMAZON',
        brand: 'Amazon India',
        body:
            'Great Indian Festival starts midnight! Up to 70% off on Smartphones, Laptops & Home Appliances. Early Prime access active: amzn.in/deals',
        receivedAt: now.subtract(const Duration(hours: 2)),
        category: CategoryType.promotional,
        classificationConfidence: 0.96,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: true,
        isStarred: false,
        isPinned: false,
        labels: [labelOffers],
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),

      // Thread 4: Government DigiLocker / Aadhaar Alert
      SmsMessage(
        id: 'msg_govt_1',
        threadId: 'thread_govt',
        sender: 'XX-GOVTIN-G',
        header: 'GOVTIN',
        brand: 'Govt of India',
        body:
            'DigiLocker: Your Driving License record has been successfully verified and issued by MoRTH. View anytime in DigiLocker app.',
        receivedAt: now.subtract(const Duration(hours: 6)),
        category: CategoryType.government,
        classificationConfidence: 0.99,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: true,
        isStarred: true,
        isPinned: false,
        labels: [labelImportant],
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),

      // Thread 5: SBI Bank (Salary Credit)
      SmsMessage(
        id: 'msg_sbi_1',
        threadId: 'thread_sbi',
        sender: 'AD-SBIINB-T',
        header: 'SBIINB',
        brand: 'SBI Bank',
        body:
            'Dear Customer, your Account ending 8912 has been credited with INR 95,000.00 towards MONTHLY SALARY on 01-Sep-26. Total Bal: INR 1,42,800.00.',
        receivedAt: now.subtract(const Duration(hours: 12)),
        category: CategoryType.transactional,
        classificationConfidence: 0.99,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: true,
        isStarred: true,
        isPinned: false,
        labels: [labelBanking, labelImportant],
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),

      // Thread 6: Zomato (Promotional coupon)
      SmsMessage(
        id: 'msg_zomato_1',
        threadId: 'thread_zomato',
        sender: 'BZ-ZOMATO-P',
        header: 'ZOMATO',
        brand: 'Zomato',
        body:
            'Craving Pizza? Use promo code CRAVINGS to get Flat 50% OFF + free delivery on top rated pizzerias near you. Order now!',
        receivedAt: now.subtract(const Duration(days: 1)),
        category: CategoryType.promotional,
        classificationConfidence: 0.97,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: true,
        isStarred: false,
        isPinned: false,
        labels: [labelOffers],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),

      // Thread 7: Flipkart (Delivery tracking)
      SmsMessage(
        id: 'msg_flipkart_1',
        threadId: 'thread_flipkart',
        sender: 'VK-FLPKRT-S',
        header: 'FLPKRT',
        brand: 'Flipkart',
        body:
            'Out for Delivery: Your Flipkart package containing Sony Headphones is out with delivery agent Vikram (PIN: 9102).',
        receivedAt: now.subtract(const Duration(days: 1, hours: 4)),
        category: CategoryType.service,
        classificationConfidence: 0.98,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: true,
        isStarred: false,
        isPinned: false,
        otp: '9102',
        labels: [labelDeliveries, labelOtp],
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),

      // Thread 8: Personal Phone Number (Category: Other)
      SmsMessage(
        id: 'msg_personal_1',
        threadId: 'thread_personal',
        sender: '+919876543210',
        header: '9876543210',
        brand: '+91 98765 43210',
        body: 'Hey! Are you free this weekend for catching up over coffee?',
        receivedAt: now.subtract(const Duration(days: 2)),
        category: CategoryType.other,
        classificationConfidence: 0.95,
        classificationReason: ClassificationReason.unknown,
        isRead: true,
        isStarred: false,
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),

      // Thread 9: Archived Message Demo
      SmsMessage(
        id: 'msg_archived_1',
        threadId: 'thread_archived',
        sender: 'VK-AIRTEL-S',
        header: 'AIRTEL',
        brand: 'Airtel',
        body:
            'Your Fiber bill for Aug 2026 of INR 1,178 is generated. Auto-debit scheduled on 05-Sep. View bill in Thanks App.',
        receivedAt: now.subtract(const Duration(days: 5)),
        category: CategoryType.service,
        classificationConfidence: 0.97,
        classificationReason: ClassificationReason.officialSuffix,
        isRead: true,
        isStarred: false,
        isPinned: false,
        isArchived: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),

      // Thread 10: Deleted Message Demo (Trash)
      SmsMessage(
        id: 'msg_deleted_1',
        threadId: 'thread_deleted',
        sender: 'XY-SPAM-P',
        header: 'SPAM',
        brand: 'Loan Offer',
        body:
            'Pre-approved instant personal loan of up to 10 Lakhs with 0 processing fee. Apply today: loan.link/apply',
        receivedAt: now.subtract(const Duration(days: 7)),
        category: CategoryType.promotional,
        classificationConfidence: 0.90,
        classificationReason: ClassificationReason.contentRule,
        isRead: true,
        isStarred: false,
        isPinned: false,
        isDeleted: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
    ];

    await messageRepo.insertMessages(sampleMessages);
    debugPrint(
      'Database seeded successfully with ${sampleMessages.length} messages and ${senders.length} sender metadata records.',
    );
  }
}
