import 'package:cloud_firestore/cloud_firestore.dart';

class GoalContribution {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;

  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
  });

  factory GoalContribution.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalContribution(
      id: doc.id,
      goalId: data['goalId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'],
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'goalId': goalId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
