class CustomerTransaction {
  final int? id;
  final int customerId;
  final String date;
  final String description;
  final double credit;
  final double debit;

  CustomerTransaction({
    this.id,
    required this.customerId,
    required this.date,
    required this.description,
    required this.credit,
    required this.debit,
  });
}