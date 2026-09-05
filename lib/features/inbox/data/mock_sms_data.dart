import 'package:delmess/core/constants/category_constants.dart';
import 'package:delmess/features/inbox/domain/sms_conversation.dart';
import 'package:delmess/features/labels/domain/label_model.dart';
import 'package:delmess/features/messages/domain/classification_reason.dart';
import 'package:delmess/features/messages/domain/sms_message.dart';

/// Isolated Mock Data for DelMess UI Development.
class MockSmsData {
  MockSmsData._();

  static final List<LabelModel> mockLabels = [
    LabelModel(
      id: 'label_finance',
      name: 'Credit Cards',
      colorValue: 0xFF00897B,
      iconCode: 0xe19f,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      messageCount: 4,
    ),
    LabelModel(
      id: 'label_food',
      name: 'Food & Groceries',
      colorValue: 0xFFE65100,
      iconCode: 0xe532,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      messageCount: 3,
    ),
    LabelModel(
      id: 'label_taxes',
      name: 'Tax & Compliance',
      colorValue: 0xFF1565C0,
      iconCode: 0xef49,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      messageCount: 2,
    ),
    LabelModel(
      id: 'label_shopping',
      name: 'E-Commerce',
      colorValue: 0xFF7B1FA2,
      iconCode: 0xf37d,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      messageCount: 3,
    ),
  ];

  static List<SmsConversation> getMockConversations() {
    final now = DateTime.now();

    final labelFinance = mockLabels[0];
    final labelFood = mockLabels[1];
    final labelTaxes = mockLabels[2];
    final labelShopping = mockLabels[3];

    return [
      // 1. Transactional - HDFC Bank UPI
      SmsConversation(
        id: 'conv_1',
        sender: 'VK-HDFCBK',
        senderDisplayName: 'HDFC Bank',
        category: CategoryType.transactional,
        isStarred: true,
        isPinned: true,
        labels: [labelFinance],
        messages: [
          SmsMessage(
            id: 'msg_101',
            threadId: 'conv_1',
            sender: 'VK-HDFCBK',
            header: 'HDFCBK',
            brand: 'HDFC Bank',
            body:
                'Sent Rs.1,450.00 from HDFC Bank A/C **8912 to Zomato UPI ref 424918239102 on 01-Sep-26. Not you? SMS BLOCK to 5676712.',
            receivedAt: now.subtract(const Duration(minutes: 12)),
            category: CategoryType.transactional,
            classificationConfidence: 0.99,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: false,
            isStarred: true,
            isPinned: true,
            labels: [labelFinance],
            createdAt: now.subtract(const Duration(minutes: 12)),
            updatedAt: now.subtract(const Duration(minutes: 12)),
          ),
          SmsMessage(
            id: 'msg_102',
            threadId: 'conv_1',
            sender: 'VK-HDFCBK',
            header: 'HDFCBK',
            brand: 'HDFC Bank',
            body:
                'Your OTP for transaction of Rs.4,999.00 on Flipkart is 839201. Valid for 10 mins. Do NOT share OTP with anyone.',
            receivedAt: now.subtract(const Duration(hours: 3)),
            category: CategoryType.transactional,
            classificationConfidence: 0.99,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            otp: '839201',
            createdAt: now.subtract(const Duration(hours: 3)),
            updatedAt: now.subtract(const Duration(hours: 3)),
          ),
        ],
      ),

      // 2. Service - Swiggy OTP & Delivery
      SmsConversation(
        id: 'conv_2',
        sender: 'AD-SWIGGY',
        senderDisplayName: 'Swiggy',
        category: CategoryType.service,
        isPinned: true,
        labels: [labelFood],
        messages: [
          SmsMessage(
            id: 'msg_201',
            threadId: 'conv_2',
            sender: 'AD-SWIGGY',
            header: 'SWIGGY',
            brand: 'Swiggy',
            body:
                '529410 is your Swiggy login OTP. Treat this as confidential. Swiggy never calls to ask for OTP.',
            receivedAt: now.subtract(const Duration(minutes: 25)),
            category: CategoryType.service,
            classificationConfidence: 0.98,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: false,
            isPinned: true,
            otp: '529410',
            labels: [labelFood],
            createdAt: now.subtract(const Duration(minutes: 25)),
            updatedAt: now.subtract(const Duration(minutes: 25)),
          ),
          SmsMessage(
            id: 'msg_202',
            threadId: 'conv_2',
            sender: 'AD-SWIGGY',
            header: 'SWIGGY',
            brand: 'Swiggy',
            body:
                'Ramesh has picked up your order from Meghana Foods! Track delivery live in the Swiggy app.',
            receivedAt: now.subtract(const Duration(hours: 5)),
            category: CategoryType.service,
            classificationConfidence: 0.98,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            createdAt: now.subtract(const Duration(hours: 5)),
            updatedAt: now.subtract(const Duration(hours: 5)),
          ),
        ],
      ),

      // 3. Government - UIDAI Aadhaar Verification
      SmsConversation(
        id: 'conv_3',
        sender: 'AX-UIDAI',
        senderDisplayName: 'UIDAI Aadhaar',
        category: CategoryType.government,
        isStarred: true,
        labels: [labelTaxes],
        messages: [
          SmsMessage(
            id: 'msg_301',
            threadId: 'conv_3',
            sender: 'AX-UIDAI',
            header: 'UIDAI',
            brand: 'UIDAI Aadhaar',
            body:
                'OTP for Aadhaar (XXX-8901) authentication is 492018. Valid for 10 minutes. Generated at 19:40 hrs. Do not share.',
            receivedAt: now.subtract(const Duration(hours: 1, minutes: 15)),
            category: CategoryType.government,
            classificationConfidence: 0.99,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: false,
            isStarred: true,
            otp: '492018',
            labels: [labelTaxes],
            createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
            updatedAt: now.subtract(const Duration(hours: 1, minutes: 15)),
          ),
        ],
      ),

      // 4. Promotional - Flipkart Big Billion Days
      SmsConversation(
        id: 'conv_4',
        sender: 'BP-FLIPKT',
        senderDisplayName: 'Flipkart',
        category: CategoryType.promotional,
        labels: [labelShopping],
        messages: [
          SmsMessage(
            id: 'msg_401',
            threadId: 'conv_4',
            sender: 'BP-FLIPKT',
            header: 'FLIPKT',
            brand: 'Flipkart',
            body:
                'MEGA SALE ALERT: Early Bird access to Big Billion Days! Up to 80% off on Smart TVs, Laptops & Audio. Shop now: fkrt.it/sale26',
            receivedAt: now.subtract(const Duration(hours: 2, minutes: 40)),
            category: CategoryType.promotional,
            classificationConfidence: 0.96,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: false,
            labels: [labelShopping],
            createdAt: now.subtract(const Duration(hours: 2, minutes: 40)),
            updatedAt: now.subtract(const Duration(hours: 2, minutes: 40)),
          ),
          SmsMessage(
            id: 'msg_402',
            threadId: 'conv_4',
            sender: 'BP-FLIPKT',
            header: 'FLIPKT',
            brand: 'Flipkart',
            body:
                'Extra 10% instant discount with HDFC/SBI Credit Cards on checkout! Free express delivery for Plus members.',
            receivedAt: now.subtract(const Duration(days: 1)),
            category: CategoryType.promotional,
            classificationConfidence: 0.96,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),

      // 5. Transactional - SBI Salary Credit
      SmsConversation(
        id: 'conv_5',
        sender: 'DZ-SBIINB',
        senderDisplayName: 'State Bank of India',
        category: CategoryType.transactional,
        isStarred: true,
        labels: [labelFinance],
        messages: [
          SmsMessage(
            id: 'msg_501',
            threadId: 'conv_5',
            sender: 'DZ-SBIINB',
            header: 'SBIINB',
            brand: 'State Bank of India',
            body:
                'Dear SBI Customer, your A/C 9841XX has been credited by Rs.95,000.00 on 31-Aug-26 by Salary NEFT txn ref N24190812. Avail Bal: Rs.1,42,850.00.',
            receivedAt: now.subtract(const Duration(days: 1, hours: 4)),
            category: CategoryType.transactional,
            classificationConfidence: 0.99,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            isStarred: true,
            labels: [labelFinance],
            createdAt: now.subtract(const Duration(days: 1, hours: 4)),
            updatedAt: now.subtract(const Duration(days: 1, hours: 4)),
          ),
        ],
      ),

      // 6. Service - Amazon Delivery Dispatch
      SmsConversation(
        id: 'conv_6',
        sender: 'AM-AMZIN',
        senderDisplayName: 'Amazon India',
        category: CategoryType.service,
        labels: [labelShopping],
        messages: [
          SmsMessage(
            id: 'msg_601',
            threadId: 'conv_6',
            sender: 'AM-AMZIN',
            header: 'AMZIN',
            brand: 'Amazon India',
            body:
                'Out for delivery: Your Amazon package with order #402-8912-9182 is arriving today by 8 PM. Share delivery code 7183 with courier agent.',
            receivedAt: now.subtract(const Duration(hours: 4)),
            category: CategoryType.service,
            classificationConfidence: 0.98,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            otp: '7183',
            labels: [labelShopping],
            createdAt: now.subtract(const Duration(hours: 4)),
            updatedAt: now.subtract(const Duration(hours: 4)),
          ),
        ],
      ),

      // 7. Government - Income Tax e-Filing
      SmsConversation(
        id: 'conv_7',
        sender: 'IT-INCOME',
        senderDisplayName: 'Income Tax Department',
        category: CategoryType.government,
        labels: [labelTaxes],
        messages: [
          SmsMessage(
            id: 'msg_701',
            threadId: 'conv_7',
            sender: 'IT-INCOME',
            header: 'INCOME',
            brand: 'Income Tax Department',
            body:
                'Refund of Rs.12,450 for AY 2026-27 has been processed and credited to your verified bank account. Reference ID: CPC/2627/981203.',
            receivedAt: now.subtract(const Duration(days: 2)),
            category: CategoryType.government,
            classificationConfidence: 0.99,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            labels: [labelTaxes],
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),

      // 8. Promotional - Domino's Pizza Offer
      SmsConversation(
        id: 'conv_8',
        sender: 'DM-DOMINO',
        senderDisplayName: "Domino's Pizza",
        category: CategoryType.promotional,
        messages: [
          SmsMessage(
            id: 'msg_801',
            threadId: 'conv_8',
            sender: 'DM-DOMINO',
            header: 'DOMINO',
            brand: "Domino's Pizza",
            body:
                'Hungry? FLAT 50% OFF up to Rs.120 on your favorite Cheese Burst pizzas! Use promo code FEAST50 on the Domino\'s App.',
            receivedAt: now.subtract(const Duration(days: 3)),
            category: CategoryType.promotional,
            classificationConfidence: 0.97,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            createdAt: now.subtract(const Duration(days: 3)),
            updatedAt: now.subtract(const Duration(days: 3)),
          ),
        ],
      ),

      // 9. Other - Broadband Service Notification / Personal
      SmsConversation(
        id: 'conv_9',
        sender: 'JK-ACTFIB',
        senderDisplayName: 'ACT Fibernet',
        category: CategoryType.other,
        messages: [
          SmsMessage(
            id: 'msg_901',
            threadId: 'conv_9',
            sender: 'JK-ACTFIB',
            header: 'ACTFIB',
            brand: 'ACT Fibernet',
            body:
                'Scheduled maintenance in your area on 02-Sep-26 from 02:00 AM to 05:00 AM. Thank you for your patience.',
            receivedAt: now.subtract(const Duration(days: 4)),
            category: CategoryType.other,
            classificationConfidence: 0.95,
            classificationReason: ClassificationReason.unknown,
            isRead: true,
            createdAt: now.subtract(const Duration(days: 4)),
            updatedAt: now.subtract(const Duration(days: 4)),
          ),
        ],
      ),

      // 10. Archived Sample - Zomato Past Order
      SmsConversation(
        id: 'conv_10',
        sender: 'AD-ZOMATO',
        senderDisplayName: 'Zomato',
        category: CategoryType.service,
        isArchived: true,
        messages: [
          SmsMessage(
            id: 'msg_1001',
            threadId: 'conv_10',
            sender: 'AD-ZOMATO',
            header: 'ZOMATO',
            brand: 'Zomato',
            body:
                'Order delivered! Rate your experience with Biryani Zone on Zomato.',
            receivedAt: now.subtract(const Duration(days: 7)),
            category: CategoryType.service,
            classificationConfidence: 0.98,
            classificationReason: ClassificationReason.officialSuffix,
            isRead: true,
            isArchived: true,
            createdAt: now.subtract(const Duration(days: 7)),
            updatedAt: now.subtract(const Duration(days: 7)),
          ),
        ],
      ),

      // 11. Deleted Sample - Spammer
      SmsConversation(
        id: 'conv_11',
        sender: 'DM-LOANS',
        senderDisplayName: 'Quick Instant Loans',
        category: CategoryType.promotional,
        isDeleted: true,
        messages: [
          SmsMessage(
            id: 'msg_1101',
            threadId: 'conv_11',
            sender: 'DM-LOANS',
            header: 'LOANS',
            brand: 'Quick Instant Loans',
            body:
                'Pre-approved instant loan up to Rs.5,00,000 without collateral! Click tiny.url/loan98 to claim in 2 mins.',
            receivedAt: now.subtract(const Duration(days: 10)),
            category: CategoryType.promotional,
            classificationConfidence: 0.90,
            classificationReason: ClassificationReason.contentRule,
            isRead: true,
            isDeleted: true,
            createdAt: now.subtract(const Duration(days: 10)),
            updatedAt: now.subtract(const Duration(days: 10)),
          ),
        ],
      ),
    ];
  }
}
