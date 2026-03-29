enum FinancialEventType { bill, income, goalMilestone }

class FinancialEvent {
  final String id;
  final String title;
  final DateTime date;
  final double amount;
  final FinancialEventType type;
  final String? note;

  const FinancialEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    this.note,
  });
}
