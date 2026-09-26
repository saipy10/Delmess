import 'package:delmess/features/classification/domain/payment_type.dart';

/// Structured result of the payment classification process.
class PaymentResult {
  final bool isPayment;
  final PaymentType type;
  final PaymentDirection direction;
  final String source;
  final String? matchedKeyword;

  const PaymentResult({
    required this.isPayment,
    this.type = PaymentType.none,
    this.direction = PaymentDirection.none,
    this.source = PaymentSource.none,
    this.matchedKeyword,
  });

  const PaymentResult.none()
      : isPayment = false,
        type = PaymentType.none,
        direction = PaymentDirection.none,
        source = PaymentSource.none,
        matchedKeyword = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentResult &&
          runtimeType == other.runtimeType &&
          isPayment == other.isPayment &&
          type == other.type &&
          direction == other.direction &&
          source == other.source &&
          matchedKeyword == other.matchedKeyword;

  @override
  int get hashCode =>
      isPayment.hashCode ^
      type.hashCode ^
      direction.hashCode ^
      source.hashCode ^
      matchedKeyword.hashCode;

  @override
  String toString() =>
      'PaymentResult(isPayment: $isPayment, type: ${type.displayName}, direction: ${direction.displayName}, source: $source)';
}
