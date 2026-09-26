import 'package:delmess/features/classification/domain/parsed_header.dart';
import 'package:delmess/features/classification/domain/payment_result.dart';
import 'package:delmess/features/classification/domain/payment_type.dart';

/// Dedicated classifier for identifying financial transactions and payment events in SMS.
///
/// Complies with Phase 7 specifications:
/// - Independent dimension from TRAI primary category.
/// - Strictly answers: "Does this message represent a financial transaction/payment event?"
/// - Protects against promotional false positives (offers, cashbacks, card solicitations).
/// - Discriminates payment events vs administrative/service messages.
class PaymentClassifier {
  const PaymentClassifier();

  // --- False-Positive Guard Regexes ---

  /// Solicitations, marketing offers, discounts, and rewards hooks
  static final RegExp _marketingOfferRegex = RegExp(
    r'(?:'
    r'get\s+(?:up\s+to\s+)?(?:\d+%|\u20B9\s*\d+|rs\.?\s*\d+)\s+cashback|'
    r'cashback\s+on\s+(?:your\s+next|all|any)|'
    r'win\s+(?:up\s+to\s+)?(?:\d+%|\u20B9\s*\d+|rs\.?\s*\d+|cashback|rewards)|'
    r'stand\s+a\s+chance\s+to|'
    r'apply\s+for\s+(?:our\s+|a\s+|new\s+)?(?:credit|debit)\s+card|'
    r'eligible\s+for\s+(?:a\s+)?(?:credit\s+card|personal\s+loan|pre-approved)|'
    r'pre[- ]approved\s+(?:offer|loan|limit|card)|'
    r'pay\s+your\s+.*?\s+and\s+get|'
    r'pay\s+.*?\s+to\s+(?:win|get|avail|earn)|'
    r'recharge\s+now\s+to\s+(?:get|win)|'
    r'avail\s+(?:flat\s+)?(?:\d+%|cashback|discount)|'
    r'use\s+code\s+[A-Z0-9]+|'
    r'limited\s+period\s+offer|'
    r'offer\s+valid\s+till|'
    r'exclusive\s+offer\s+for\s+you|'
    r'upgrade\s+your\s+card'
    r')',
    caseSensitive: false,
  );

  /// Administrative, statements, dispatch notices without transaction events
  static final RegExp _administrativeNoticeRegex = RegExp(
    r'(?:'
    r'cheque\s+book\s+(?:has\s+been\s+)?(?:dispatched|delivered|issued)|'
    r'(?:e-?statement|account\s+statement)\s+for|'
    r'card\s+(?:has\s+been\s+)?(?:dispatched|blocked|unblocked)|'
    r'pin\s+(?:has\s+been\s+)?changed|'
    r'update\s+your\s+kyc|'
    r'kyc\s+is\s+due|'
    r'bill\s+is\s+due|'
    r'due\s+date\s+is|'
    r'minimum\s+amount\s+due|'
    r'bill\s+generated'
    r')',
    caseSensitive: false,
  );

  /// Payment request / UPI collect request (not an executed payment)
  static final RegExp _paymentRequestRegex = RegExp(
    r'(?:'
    r'has\s+requested\s+money\s+from\s+you|'
    r'payment\s+request\s+of|'
    r'collect\s+request\s+of'
    r')',
    caseSensitive: false,
  );

  // --- Genuine Transaction Event Regexes ---

  /// Explicit debit transaction indicators
  static final RegExp _debitExecutionRegex = RegExp(
    r'(?:'
    r'(?:\u20B9|rs\.?|inr)\s*[\d,]+(?:\.\d{2})?\s*(?:has\s+been\s+|was\s+|is\s+)?debited|'
    r'debited\s*(?:by|with|for)?\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+|'
    r'debited\s+from\s+(?:a/c|account)|'
    r'(?:\u20B9|rs\.?|inr)\s*[\d,]+(?:\.\d{2})?\s*deducted|'
    r'deducted\s+from\s+(?:a/c|account)|'
    r'withdrawn\s*(?:from|at)?|'
    r'cash\s+withdrawal|'
    r'(?:was\s+|has\s+been\s+)?charged\s*(?:\u20B9|rs\.?|inr)\s*[\d,]+|'
    r'spent\s*(?:\u20B9|rs\.?|inr)\s*[\d,]+|'
    r'paid\s*(?:\u20B9|rs\.?|inr)\s*[\d,]+|'
    r'sent\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+'
    r')',
    caseSensitive: false,
  );

  /// Explicit credit transaction indicators
  static final RegExp _creditExecutionRegex = RegExp(
    r'(?:'
    r'(?:\u20B9|rs\.?|inr)\s*[\d,]+(?:\.\d{2})?\s*(?:has\s+been\s+|was\s+|is\s+)?credited|'
    r'credited\s*(?:by|with|for)?\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+|'
    r'credited\s+to\s+(?:a/c|account)|'
    r'(?:\u20B9|rs\.?|inr)\s*[\d,]+(?:\.\d{2})?\s*deposited|'
    r'deposited\s+in\s+(?:a/c|account)|'
    r'received\s*(?:\u20B9|rs\.?|inr)\s*[\d,]+|'
    r'(?:refund|cashback)\s+of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+.*?(?:credited|processed|received)|'
    r'cashback\s+received'
    r')',
    caseSensitive: false,
  );

  /// Successful transaction confirmations
  static final RegExp _successfulTxnRegex = RegExp(
    r'(?:'
    r'(?:payment|transaction|txn|transfer|neft|rtgs|imps)\s+of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+.*?(?:successful|processed|completed)|'
    r'bill\s+payment\s+of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+.*?(?:successful|received)|'
    r'recharge\s+of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+.*?(?:successful|completed)|'
    r'electricity\s+bill\s+payment\s+of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+.*?(?:successful|received)|'
    r'(?:successful|completed)\s+(?:payment|transaction|recharge|transfer)\s+of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+'
    r')',
    caseSensitive: false,
  );

  /// Payment authorization accompanying an OTP (e.g. UPI payment authorization)
  static final RegExp _paymentAuthorizationRegex = RegExp(
    r'(?:'
    r'otp\s+(?:for|to\s+authorize)\s+.*?(?:payment|upi|txn|transaction|card\s+payment|transfer)|'
    r'authorize\s+(?:the\s+)?(?:payment|txn|transaction|transfer)\s+of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+|'
    r'otp\s+is\s+\d+\s+for\s+(?:txn|payment|purchase)'
    r')',
    caseSensitive: false,
  );

  // --- Specific Payment Types ---

  static final RegExp _atmCashRegex = RegExp(
    r'(?:atm\s+(?:cash\s+)?withdrawal|withdrawn\s+(?:at|from)\s+atm|cash\s+withdrawn|cash\s+withdrawal)',
    caseSensitive: false,
  );

  static final RegExp _refundRegex = RegExp(
    r'(?:refund\s+(?:of|processed|credited|initiated)|cashback\s+(?:received|credited))',
    caseSensitive: false,
  );

  static final RegExp _rechargeRegex = RegExp(
    r'(?:recharge\s+(?:of\s*(?:\u20B9|rs\.?|inr)?\s*[\d,]+|successful)|mobile\s+recharge|dth\s+recharge)',
    caseSensitive: false,
  );

  static final RegExp _billPaymentRegex = RegExp(
    r'(?:bill\s+payment|electricity\s+bill|water\s+bill|gas\s+bill|broadband\s+bill|utility\s+bill)',
    caseSensitive: false,
  );

  static final RegExp _upiRegex = RegExp(
    r'(?:\bupi\b|vpa|@(?:okhdfcbank|oksbi|okaxis|okicici|paytm|ybl|apl|upi)\b|upi\s+ref|upi\s+transaction|upi\s+payment)',
    caseSensitive: false,
  );

  static final RegExp _cardRegex = RegExp(
    r'(?:credit\s+card|debit\s+card|card\s+ending\s+(?:in|with)?\s*\d+|charged\s+on\s+card|card\s+transaction|\bpos\b)',
    caseSensitive: false,
  );

  static final RegExp _transferRegex = RegExp(
    r'(?:\bneft\b|\brtgs\b|\bimps\b|bank\s+transfer|transfer\s+to\s+a/c|transferred\s+via)',
    caseSensitive: false,
  );

  /// Evaluates whether an SMS represents an actual financial payment/transaction event.
  PaymentResult classify(String body, {ParsedHeader? parsedHeader}) {
    final lower = body.toLowerCase().trim();

    // 1. Guard against marketing/solicitation false positives
    // Note: If a message says "Get 5% cashback on your next UPI payment", it matches
    // the marketing regex. Even if it contains "UPI payment", it is not a payment event.
    if (_marketingOfferRegex.hasMatch(lower)) {
      // Unless it also contains an unambiguous past-tense debit or completed transaction
      final hasCompletedDebit =
          _debitExecutionRegex.hasMatch(lower) &&
          (lower.contains('debited') ||
              lower.contains('was charged') ||
              lower.contains('spent ₹') ||
              lower.contains('spent rs'));
      final hasCompletedCredit =
          _creditExecutionRegex.hasMatch(lower) &&
          (lower.contains('credited') || lower.contains('cashback received'));

      if (!hasCompletedDebit && !hasCompletedCredit) {
        return const PaymentResult.none();
      }
    }

    // 2. Guard against administrative notices without execution
    if (_administrativeNoticeRegex.hasMatch(lower)) {
      final hasCompletedExecution =
          _debitExecutionRegex.hasMatch(lower) ||
          _creditExecutionRegex.hasMatch(lower) ||
          _successfulTxnRegex.hasMatch(lower);

      if (!hasCompletedExecution) {
        return const PaymentResult.none();
      }
    }

    // 3. Guard against payment requests (UPI collect requests that have not been executed)
    if (_paymentRequestRegex.hasMatch(lower) &&
        !lower.contains('successful') &&
        !lower.contains('debited')) {
      return const PaymentResult.none();
    }

    // 4. Check for genuine transaction execution
    final isDebit = _debitExecutionRegex.hasMatch(lower);
    final isCredit = _creditExecutionRegex.hasMatch(lower);
    final isSuccessTxn = _successfulTxnRegex.hasMatch(lower);
    final isAuthorization = _paymentAuthorizationRegex.hasMatch(lower);
    final isAtm = _atmCashRegex.hasMatch(lower);
    final isTransfer = _transferRegex.hasMatch(lower) &&
        (lower.contains('successful') ||
            lower.contains('sent') ||
            lower.contains('received') ||
            lower.contains('completed') ||
            lower.contains('₹') ||
            lower.contains('rs'));

    if (!isDebit && !isCredit && !isSuccessTxn && !isAuthorization && !isAtm && !isTransfer) {
      return const PaymentResult.none();
    }

    // 5. Determine PaymentDirection
    final PaymentDirection direction;
    if (isAtm) {
      direction = PaymentDirection.debit;
    } else if (isDebit) {
      direction = PaymentDirection.debit;
    } else if (isCredit) {
      direction = PaymentDirection.credit;
    } else if (isAuthorization) {
      direction = PaymentDirection.debit;
    } else if (isTransfer) {
      direction = lower.contains('received')
          ? PaymentDirection.credit
          : PaymentDirection.debit;
    } else if (isSuccessTxn) {
      if (lower.contains('received') ||
          lower.contains('credit') ||
          lower.contains('refund')) {
        direction = PaymentDirection.credit;
      } else {
        direction = PaymentDirection.debit;
      }
    } else {
      direction = PaymentDirection.unknown;
    }

    // 6. Determine PaymentType with prioritized specificity
    final PaymentType type;
    if (_atmCashRegex.hasMatch(lower)) {
      type = PaymentType.cashWithdrawal;
    } else if (_refundRegex.hasMatch(lower)) {
      type = PaymentType.refund;
    } else if (_rechargeRegex.hasMatch(lower)) {
      type = PaymentType.recharge;
    } else if (_billPaymentRegex.hasMatch(lower)) {
      type = PaymentType.billPayment;
    } else if (_upiRegex.hasMatch(lower)) {
      type = PaymentType.upi;
    } else if (_cardRegex.hasMatch(lower)) {
      type = PaymentType.card;
    } else if (_transferRegex.hasMatch(lower)) {
      type = PaymentType.bankTransfer;
    } else if (isDebit) {
      type = PaymentType.debit;
    } else if (isCredit) {
      type = PaymentType.credit;
    } else {
      type = PaymentType.payment;
    }

    return PaymentResult(
      isPayment: true,
      type: type,
      direction: direction,
      source: PaymentSource.paymentPattern,
      matchedKeyword: type.displayName,
    );
  }
}
