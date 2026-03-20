
class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final String brand;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.brand,
    this.isDefault = false,
  });
}

class Transaction {
  final String id;
  final String date;
  final String description;
  final double amount;
  final String status;

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.status,
  });
}
