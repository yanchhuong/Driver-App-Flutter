class PaymentModel {
  final int id;
  final int tripId;
  final double? amount;
  final String currency;
  final String status;  // PENDING | COMPLETED | FAILED | REFUNDED
  final String? method; // CASH | CREDIT_CARD | DEBIT_CARD | WALLET
  final String? transactionReference;
  final String? processedAt;

  PaymentModel({
    required this.id,
    required this.tripId,
    this.amount,
    required this.currency,
    required this.status,
    this.method,
    this.transactionReference,
    this.processedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
        id: j['id'],
        tripId: j['trip']?['id'] ?? j['tripId'] ?? 0,
        amount: j['amount']?.toDouble(),
        currency: j['currency'] ?? 'USD',
        status: j['status'] ?? 'PENDING',
        method: j['method'],
        transactionReference: j['transactionReference'],
        processedAt: j['processedAt'],
      );
}
