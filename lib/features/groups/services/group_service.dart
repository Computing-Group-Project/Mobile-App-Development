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

  Future<void> createGroup({
    required String name,
    required String createdBy,
    required List<GroupMember> members,
  }) async {
    await _db.collection('groups').add({
      'name': name,
      'createdBy': createdBy,
      'members': members.map((m) => m.toMap()).toList(),
      'memberIds': members.map((m) => m.uid).toList(),
      'createdAt': Timestamp.now(),
      'totalExpenses': 0.0,
    });
  }

  Future<void> addExpense(SharedExpense expense) async {
    final groupRef = _db.collection('groups').doc(expense.groupId);
    final expRef = groupRef.collection('expenses').doc();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(groupRef);
      final current = (snap.data()?['totalExpenses'] ?? 0).toDouble();

      tx.set(expRef, expense.toMap());

      tx.update(groupRef, {
        'totalExpenses': current + expense.totalAmount,
      });
    });
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
        .map((snapshot) => snapshot.docs
        .map((doc) => Settlement.fromMap(doc.id, doc.data()))
        .toList());
  }
}
