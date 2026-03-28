// Recurring transaction model for the finance module
class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String frequency; // e.g., 'weekly', 'monthly', etc.
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
  });
}