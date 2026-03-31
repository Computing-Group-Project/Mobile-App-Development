import 'package:cloud_firestore/cloud_firestore.dart';

class Settlement {
  final String id;
  final String groupId;
  final String fromUid;
  final String fromName;
  final String toUid;
  final String toName;
  final double amount;
  final DateTime createdAt;
  final bool isPartial;

  Settlement({
    required this.id,
    required this.groupId,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.amount,
    required this.createdAt,
    this.isPartial = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'fromUid': fromUid,
      'fromName': fromName,
      'toUid': toUid,
      'toName': toName,
      'amount': amount,
      'createdAt': createdAt,
      'isPartial': isPartial,
    };
  }

  factory Settlement.fromMap(String id, Map<String, dynamic> map) {
    return Settlement(
      id: id,
      groupId: map['groupId'],
      fromUid: map['fromUid'],
      fromName: map['fromName'],
      toUid: map['toUid'],
      toName: map['toName'],
      amount: (map['amount'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(), // ✅ Timestamp now recognized
      isPartial: map['isPartial'] ?? false,
    );
  }
}
