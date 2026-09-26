/// Payment transaction types identified by DelMess.
enum PaymentType {
  none,
  payment,
  debit,
  credit,
  upi,
  card,
  bankTransfer,
  refund,
  cashWithdrawal,
  recharge,
  billPayment,
  other;

  String get displayName {
    switch (this) {
      case PaymentType.none:
        return 'None';
      case PaymentType.payment:
        return 'Payment';
      case PaymentType.debit:
        return 'Debit';
      case PaymentType.credit:
        return 'Credit';
      case PaymentType.upi:
        return 'UPI';
      case PaymentType.card:
        return 'Card';
      case PaymentType.bankTransfer:
        return 'Bank Transfer';
      case PaymentType.refund:
        return 'Refund';
      case PaymentType.cashWithdrawal:
        return 'Cash Withdrawal';
      case PaymentType.recharge:
        return 'Recharge';
      case PaymentType.billPayment:
        return 'Bill Payment';
      case PaymentType.other:
        return 'Other';
    }
  }

  String get dbValue {
    switch (this) {
      case PaymentType.none:
        return 'NONE';
      case PaymentType.payment:
        return 'PAYMENT';
      case PaymentType.debit:
        return 'DEBIT';
      case PaymentType.credit:
        return 'CREDIT';
      case PaymentType.upi:
        return 'UPI';
      case PaymentType.card:
        return 'CARD';
      case PaymentType.bankTransfer:
        return 'TRANSFER';
      case PaymentType.refund:
        return 'REFUND';
      case PaymentType.cashWithdrawal:
        return 'CASH_WITHDRAWAL';
      case PaymentType.recharge:
        return 'RECHARGE';
      case PaymentType.billPayment:
        return 'BILL_PAYMENT';
      case PaymentType.other:
        return 'OTHER';
    }
  }

  static PaymentType fromString(String? value) {
    if (value == null) return PaymentType.none;
    final upper = value.toUpperCase().trim();
    switch (upper) {
      case 'PAYMENT':
        return PaymentType.payment;
      case 'DEBIT':
        return PaymentType.debit;
      case 'CREDIT':
        return PaymentType.credit;
      case 'UPI':
        return PaymentType.upi;
      case 'CARD':
        return PaymentType.card;
      case 'TRANSFER':
      case 'BANK_TRANSFER':
      case 'BANKTRANSFER':
        return PaymentType.bankTransfer;
      case 'REFUND':
        return PaymentType.refund;
      case 'CASH_WITHDRAWAL':
      case 'CASHWITHDRAWAL':
        return PaymentType.cashWithdrawal;
      case 'RECHARGE':
        return PaymentType.recharge;
      case 'BILL_PAYMENT':
      case 'BILLPAYMENT':
        return PaymentType.billPayment;
      case 'OTHER':
        return PaymentType.other;
      case 'NONE':
      default:
        return PaymentType.none;
    }
  }
}

/// Payment direction: Debit, Credit, or Unknown.
enum PaymentDirection {
  none,
  debit,
  credit,
  unknown;

  String get displayName {
    switch (this) {
      case PaymentDirection.none:
        return 'None';
      case PaymentDirection.debit:
        return 'Debit';
      case PaymentDirection.credit:
        return 'Credit';
      case PaymentDirection.unknown:
        return 'Unknown';
    }
  }

  String get dbValue {
    switch (this) {
      case PaymentDirection.none:
        return 'NONE';
      case PaymentDirection.debit:
        return 'DEBIT';
      case PaymentDirection.credit:
        return 'CREDIT';
      case PaymentDirection.unknown:
        return 'UNKNOWN';
    }
  }

  static PaymentDirection fromString(String? value) {
    if (value == null) return PaymentDirection.none;
    final upper = value.toUpperCase().trim();
    switch (upper) {
      case 'DEBIT':
        return PaymentDirection.debit;
      case 'CREDIT':
        return PaymentDirection.credit;
      case 'UNKNOWN':
        return PaymentDirection.unknown;
      case 'NONE':
      default:
        return PaymentDirection.none;
    }
  }
}

/// Explicit classification source constants.
class CategorySource {
  static const String traiSuffix = 'TRAI_SUFFIX';
  static const String knownHeader = 'KNOWN_HEADER';
  static const String contentPattern = 'CONTENT_PATTERN';
  static const String manual = 'MANUAL';
  static const String fallback = 'FALLBACK';
}

/// Explicit payment source constants.
class PaymentSource {
  static const String paymentPattern = 'PAYMENT_PATTERN';
  static const String none = 'NONE';
}

/// Explicit OTP source constants.
class OtpSource {
  static const String otpPattern = 'OTP_PATTERN';
  static const String none = 'NONE';
}
