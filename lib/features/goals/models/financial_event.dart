import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory FinancialEvent.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialEvent(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      amount: (data['amount'] ?? 0).toDouble(),
      type: FinancialEventType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => FinancialEventType.bill,
      ),
      note: data['note'],
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'type': type.name,
      'note': note,
    };
  }
}
