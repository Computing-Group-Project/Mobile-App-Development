import '../models/budget.dart';

class BudgetService {
  final List<Budget> _storage = [];

  List<Budget> getAll() => List.unmodifiable(_storage);

  void add(Budget budget) {
    _storage.add(budget);
  }

  void remove(String id) {
    _storage.removeWhere((b) => b.id == id);
  }

  void update(Budget updated) {
    final index = _storage.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      _storage[index] = updated;
    }
  }
}