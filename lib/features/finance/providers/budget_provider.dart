import 'package:flutter/material.dart';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final List<Budget> _budgets = [];

  List<Budget> get budgets => List.unmodifiable(_budgets);

  void addBudget(Budget budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  void removeBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void updateBudget(Budget updated) {
    final index = _budgets.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      _budgets[index] = updated;
      notifyListeners();
    }
  }
}