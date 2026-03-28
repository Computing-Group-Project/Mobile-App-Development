import '../models/transaction.dart';

class TransactionService {
  final List<Transaction> _storage = [];

  List<Transaction> getAll() => List.unmodifiable(_storage);

  void add(Transaction transaction) {
    _storage.add(transaction);
  }

  void remove(String id) {
    _storage.removeWhere((t) => t.id == id);
  }

  void update(Transaction updated) {
    final index = _storage.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _storage[index] = updated;
    }
  }
}