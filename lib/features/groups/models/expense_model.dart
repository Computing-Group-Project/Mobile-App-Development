import 'package:cloud_firestore/cloud_firestore.dart';

enum SplitType { equal, custom, percentage }

class MemberSplit {
  final String uid;
  final String name;
  final double amount;
  final double? percentage;
  bool isPaid;

  MemberSplit({
    required this.uid,
    required this.name,
    required this.amount,
    this.percentage,
    this.isPaid = false,
  });

  factory MemberSplit.fromMap(Map<String, dynamic> map) => MemberSplit(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        amount: (map['amount'] ?? 0.0).toDouble(),
        percentage: map['percentage']?.toDouble(),
        isPaid: map['isPaid'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'amount': amount,
        'percentage': percentage,
        'isPaid': isPaid,
      };
}

class SharedExpense {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final double totalAmount;
  final String paidBy;
  final String paidByName;
  final SplitType splitType;
  final List<MemberSplit> splits;
  final DateTime createdAt;
  final String category;

  SharedExpense({
    required this.id,
    required this.groupId,
    required this.title,
    this.description = '',
    required this.totalAmount,
    required this.paidBy,
    required this.paidByName,
    required this.splitType,
    required this.splits,
    required this.createdAt,
    this.category = 'General',
  });

  factory SharedExpense.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharedExpense(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      paidBy: data['paidBy'] ?? '',
      paidByName: data['paidByName'] ?? '',
      splitType: SplitType.values.firstWhere(
        (e) => e.name == (data['splitType'] ?? 'equal'),
        orElse: () => SplitType.equal,
      ),
      splits: (data['splits'] as List<dynamic>? ?? [])
          .map((s) => MemberSplit.fromMap(s))
          .toList(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toMap() => {
        'groupId': groupId,
        'title': title,
        'description': description,
        'totalAmount': totalAmount,
        'paidBy': paidBy,
        'paidByName': paidByName,
        'splitType': splitType.name,
        'splits': splits.map((s) => s.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'category': category,
      };
}