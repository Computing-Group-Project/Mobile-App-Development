import 'package:flutter/material.dart';
import '../models/recurring_transaction.dart';

class RecurringTransactionProvider extends ChangeNotifier {
  final List<RecurringTransaction> _recurringTransactions = [];

  List<RecurringTransaction> get recurringTransactions => List.unmodifiable(_recurringTransactions);

  void addRecurringTransaction(RecurringTransaction transaction) {
    _recurringTransactions.add(transaction);
    notifyListeners();
  }

  void removeRecurringTransaction(String id) {
    _recurringTransactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateRecurringTransaction(RecurringTransaction updated) {
    final index = _recurringTransactions.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _recurringTransactions[index] = updated;
      notifyListeners();
    }
  }
}