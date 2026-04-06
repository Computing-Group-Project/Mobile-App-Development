import 'package:cloud_firestore/cloud_firestore.dart';

class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String frequency; // 'weekly', 'monthly', etc.
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final String type; // 'income' or 'expense'

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.frequency,
    required this.startDate,
    required this.type,
    this.endDate,
    this.notes,
  });

  factory RecurringTransaction.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecurringTransaction(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      frequency: data['frequency'] ?? 'monthly',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      type: data['type'] ?? 'expense',
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'notes': notes,
      'type': type,
    };
  }
}
