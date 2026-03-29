import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service = AnalyticsService();

  List<Transaction> _transactions = [];
  bool _isLoading = false;

  // ─── Getters ───────────────────────────────────────────────────────────────
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

  // ─── Load Fake Data (swap with Firestore later) ────────────────────────────
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    // Simulating a small delay like a real fetch
    await Future.delayed(const Duration(milliseconds: 500));

    _transactions = _service.getFakeTransactions();
    _isLoading = false;
    notifyListeners();
  }
}
