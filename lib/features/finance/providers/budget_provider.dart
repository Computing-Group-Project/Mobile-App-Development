import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _col => _db.collection('budgets');

  Stream<List<Budget>> get budgetsStream {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Budget.fromDoc).toList());
  }

  Future<void> addBudget(Budget budget) async {
    final uid = _uid;
    if (uid == null) return;
    await _col.add(budget.toMap(uid));
  }

  Future<void> removeBudget(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> updateBudget(Budget updated) async {
    final uid = _uid;
    if (uid == null) return;
    await _col.doc(updated.id).update(updated.toMap(uid));
  }
}
