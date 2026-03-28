import '../models/recurring_transaction.dart';

class RecurringTransactionService {
  final List<RecurringTransaction> _storage = [];

  List<RecurringTransaction> getAll() => List.unmodifiable(_storage);

  void add(RecurringTransaction transaction) {
    _storage.add(transaction);
  }

  void remove(String id) {
    _storage.removeWhere((t) => t.id == id);
  }

  void update(RecurringTransaction updated) {
    final index = _storage.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _storage[index] = updated;
    }
  }
}