import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String description;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.description,
  });

  factory Transaction.fromDoc(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] ?? 'expense',
      description: map['title'] ?? map['description'] ?? '',
    );
  }
}
