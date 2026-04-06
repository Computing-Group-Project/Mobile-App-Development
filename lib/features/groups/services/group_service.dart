import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';

class GroupService {
  final _db = FirebaseFirestore.instance;

  Stream<List<GroupModel>> streamUserGroups(String uid) {
    return _db
        .collection('groups')
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((s) => s.docs.map((d) => GroupModel.fromDoc(d)).toList());
  }

  Stream<List<SharedExpense>> streamGroupExpenses(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SharedExpense.fromDoc(d)).toList());
  }

  Future<String> createGroup({
    required String name,
    required String createdBy,
    required List<GroupMember> members,
  }) async {
    final ref = await _db.collection('groups').add({
      'name': name,
      'createdBy': createdBy,
      'members': members.map((m) => m.toMap()).toList(),
      'memberIds': members.map((m) => m.uid).toList(),
      'createdAt': Timestamp.now(),
      'totalExpenses': 0.0,
    });
    return ref.id;
  }

  Future<void> addExpense(SharedExpense expense) async {
    final groupRef = _db.collection('groups').doc(expense.groupId);
    final expRef = groupRef.collection('expenses').doc();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(groupRef);
      final current = (snap.data()?['totalExpenses'] ?? 0).toDouble();
      tx.set(expRef, expense.toMap());
      tx.update(groupRef, {'totalExpenses': current + expense.totalAmount});
    });

    // Notify every member except the payer
    final groupSnap = await groupRef.get();
    final members = List<Map<String, dynamic>>.from(
        (groupSnap.data() as Map<String, dynamic>?)?['members'] ?? []);
    final groupName = (groupSnap.data() as Map<String, dynamic>?)?['name'] ?? '';

    for (final member in members) {
      final uid = member['uid'] as String? ?? '';
      if (uid.isEmpty || uid == expense.paidBy) continue;

      final myShare = expense.splits
          .firstWhere((s) => s.uid == uid,
              orElse: () => MemberSplit(uid: '', name: '', amount: 0))
          .amount;

      await _writeNotification(
        uid: uid,
        title: 'New Expense in $groupName',
        body: '${expense.paidByName} added "${expense.title}" '
            '— your share is LKR ${myShare.toStringAsFixed(0)}.',
        type: 'groupActivity',
      );
    }
  }

  Future<void> recordSettlement(Settlement settlement) async {
    final ref = _db
        .collection('groups')
        .doc(settlement.groupId)
        .collection('settlements')
        .doc();

    await ref.set({
      ...settlement.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Settlement>> streamSettlements(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((doc) => Settlement.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Removes [uid] from the group's members list.
  /// If it was the last member, the group is deleted entirely.
  Future<void> leaveGroup(String groupId, String uid) async {
    final groupRef = _db.collection('groups').doc(groupId);
    final snap = await groupRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final members = List<Map<String, dynamic>>.from(data['members'] ?? []);
    final memberIds = List<String>.from(data['memberIds'] ?? []);

    members.removeWhere((m) => m['uid'] == uid);
    memberIds.remove(uid);

    if (members.isEmpty) {
      await _deleteGroup(groupId);
    } else {
      await groupRef.update({'members': members, 'memberIds': memberIds});
    }
  }

  /// Deletes the group and all its sub-collections.
  Future<void> deleteGroup(String groupId) => _deleteGroup(groupId);

  Future<void> _writeNotification({
    required String uid,
    required String title,
    required String body,
    required String type,
  }) async {
    await _db.collection('users').doc(uid).collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<void> _deleteGroup(String groupId) async {
    final groupRef = _db.collection('groups').doc(groupId);

    final expenses = await groupRef.collection('expenses').get();
    for (final doc in expenses.docs) {
      await doc.reference.delete();
    }

    final settlements = await groupRef.collection('settlements').get();
    for (final doc in settlements.docs) {
      await doc.reference.delete();
    }

    await groupRef.delete();
  }
}
