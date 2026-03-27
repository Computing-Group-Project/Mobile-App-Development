class Transaction {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String type; // "income" or "expense"
  final String description;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.description,
  });

  // Convert Firestore data to Transaction object (use later when real data is ready)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
      type: map['type'] ?? 'expense',
      description: map['description'] ?? '',
    );
  }

  // Convert Transaction object to Map (use later for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
    };
  }
}
