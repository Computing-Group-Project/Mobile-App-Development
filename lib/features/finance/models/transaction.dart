import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isRecurring;
  final String? notes;
  final String type; // 'income' or 'expense'

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.isRecurring = false,
    this.notes,
  });

  factory Transaction.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] ?? '',
      type: data['type'] ?? 'expense',
      isRecurring: data['isRecurring'] ?? false,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'type': type,
      'isRecurring': isRecurring,
      'notes': notes,
    };
  }
}
