import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMember {
  final String uid;
  final String name;
  final String email;

  GroupMember({required this.uid, required this.name, required this.email});

  factory GroupMember.fromMap(Map<String, dynamic> map) => GroupMember(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
      };
}

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final List<GroupMember> members;
  final DateTime createdAt;
  final double totalExpenses;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.createdAt,
    this.totalExpenses = 0.0,
  });

  factory GroupModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      members: (data['members'] as List<dynamic>? ?? [])
          .map((m) => GroupMember.fromMap(m))
          .toList(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalExpenses: (data['totalExpenses'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdBy': createdBy,
        'members': members.map((m) => m.toMap()).toList(),
        'memberIds': members.map((m) => m.uid).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'totalExpenses': totalExpenses,
      };
}