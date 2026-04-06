import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/recurring_transaction.dart';
import '../../../features/notifications/services/notification_service.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _col => _db.collection('recurringTransactions');

  Stream<List<RecurringTransaction>> get recurringTransactionsStream {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('userId', isEqualTo: uid)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map(RecurringTransaction.fromDoc).toList());
  }

  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    final uid = _uid;
    if (uid == null) return;
    await _col.add(transaction.toMap(uid));

    // Schedule a bill reminder 1 day before the first due date
    if (transaction.type == 'expense') {
      await NotificationService().scheduleBillReminder(
        id: transaction.title.hashCode ^ transaction.startDate.hashCode,
        billName: transaction.title,
        dueDate: transaction.startDate,
      );
    }
  }

  Future<void> removeRecurringTransaction(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> updateRecurringTransaction(RecurringTransaction updated) async {
    final uid = _uid;
    if (uid == null) return;
    await _col.doc(updated.id).update(updated.toMap(uid));
  }
}
