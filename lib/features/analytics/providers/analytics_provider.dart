import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _service.getTotalIncome(_transactions);
  double get totalExpense => _service.getTotalExpense(_transactions);
  Map<String, double> get spendingByCategory =>
      _service.getSpendingByCategory(_transactions);
  Map<String, Map<String, double>> get monthlyTotals =>
      _service.getMonthlyTotals(_transactions);
  Map<DateTime, double> get dailySpending =>
      _service.getDailySpending(_transactions);
  List<String> get insights => _service.getInsights(_transactions);

  Future<void> loadTransactions() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('transactions')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();

      _transactions = snapshot.docs.map(Transaction.fromDoc).toList();
    } catch (e) {
      debugPrint('AnalyticsProvider.loadTransactions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
