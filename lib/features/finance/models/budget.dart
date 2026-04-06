import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String id;
  final String name;
  final double limit;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> categories;

  Budget({
    required this.id,
    required this.name,
    required this.limit,
    required this.startDate,
    required this.endDate,
    required this.categories,
  });

  factory Budget.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      id: doc.id,
      name: data['name'] ?? '',
      limit: (data['limit'] ?? 0).toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      categories: List<String>.from(data['categories'] ?? []),
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'name': name,
      'limit': limit,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'categories': categories,
    };
  }
}
