import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../../../features/notifications/services/notification_service.dart';

class TransactionProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _col => _db.collection('transactions');

  Stream<List<Transaction>> get transactionsStream {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: uid)
        .where('isRecurring', isEqualTo: false)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Transaction.fromDoc).toList());
  }

  Future<void> addTransaction(Transaction transaction) async {
    final uid = _uid;
    if (uid == null) return;
    await _col.add(transaction.toMap(uid));

    // Check budget alerts for expense transactions
    if (transaction.type == 'expense') {
      await _checkBudgetAlert(uid, transaction);
    }
  }

  Future<void> removeTransaction(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> updateTransaction(Transaction updated) async {
    final uid = _uid;
    if (uid == null) return;
    await _col.doc(updated.id).update(updated.toMap(uid));
  }

  Future<void> _checkBudgetAlert(String uid, Transaction transaction) async {
    try {
      // Fetch budgets that cover this transaction's category
      final budgetSnap = await _db
          .collection('budgets')
          .where('userId', isEqualTo: uid)
          .where('categories', arrayContains: transaction.category)
          .get();

      if (budgetSnap.docs.isEmpty) return;

      final now = transaction.date;

      for (final doc in budgetSnap.docs) {
        final budget = Budget.fromDoc(doc);

        // Check budget is active (transaction date falls within range)
        if (now.isBefore(budget.startDate) || now.isAfter(budget.endDate)) {
          continue;
        }

        // Sum all expenses in this category within the budget date range
        final txSnap = await _db
            .collection('transactions')
            .where('userId', isEqualTo: uid)
            .where('type', isEqualTo: 'expense')
            .where('category', isEqualTo: transaction.category)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(budget.startDate))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(budget.endDate))
            .get();

        final spent = txSnap.docs.fold<double>(
          0,
          (sum, d) => sum + ((d['amount'] ?? 0) as num).toDouble(),
        );

        final percent = spent / budget.limit;
        if (percent >= 0.8) {
          await NotificationService().showBudgetAlert(
            category: transaction.category,
            spent: spent,
            cap: budget.limit,
          );
        }
      }
    } catch (e) {
      debugPrint('Budget alert check failed: $e');
    }
  }
}
