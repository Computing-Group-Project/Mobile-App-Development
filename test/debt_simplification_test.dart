import 'package:flutter_test/flutter_test.dart';
import 'package:fundflow/features/groups/services/debt_simplification.dart';
import 'package:fundflow/features/groups/models/expense_model.dart';

void main() {
  group('Debt Simplification Algorithm', () {
    test('produces correct net balances', () {
      final expenses = [
        SharedExpense(
          id: '1',
          groupId: 'g1',
          title: 'Dinner',
          description: 'Pizza night',
          totalAmount: 60,
          paidBy: 'alice',
          paidByName: 'Alice',
          splitType: SplitType.equal,
          splits: [
            MemberSplit(uid: 'alice', name: 'Alice', amount: 20, percentage: null, isPaid: true),
            MemberSplit(uid: 'bob', name: 'Bob', amount: 20, percentage: null, isPaid: false),
            MemberSplit(uid: 'charlie', name: 'Charlie', amount: 20, percentage: null, isPaid: false),
          ],
          createdAt: DateTime.now(),
          category: 'Food',
        ),
        SharedExpense(
          id: '2',
          groupId: 'g1',
          title: 'Movie',
          description: 'Tickets',
          totalAmount: 45,
          paidBy: 'bob',
          paidByName: 'Bob',
          splitType: SplitType.equal,
          splits: [
            MemberSplit(uid: 'alice', name: 'Alice', amount: 15, percentage: null, isPaid: false),
            MemberSplit(uid: 'bob', name: 'Bob', amount: 15, percentage: null, isPaid: true),
            MemberSplit(uid: 'charlie', name: 'Charlie', amount: 15, percentage: null, isPaid: false),
          ],
          createdAt: DateTime.now(),
          category: 'Entertainment',
        ),
      ];

      final settlements = simplifyDebts(expenses);

      // Compute net balances from settlements
      final Map<String, double> netBalances = {};
      for (var s in settlements) {
        netBalances[s.from] = (netBalances[s.from] ?? 0) - s.amount;
        netBalances[s.to] = (netBalances[s.to] ?? 0) + s.amount;
      }

      expect(netBalances['alice']?.round(), 25);
      expect(netBalances['bob']?.round(), 10);
      expect(netBalances['charlie']?.round(), -35);
    });
  });
}
