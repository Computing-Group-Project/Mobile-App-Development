// Transaction model for the finance module
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isRecurring;
  final String? notes;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.isRecurring = false,
    this.notes,
  });
}