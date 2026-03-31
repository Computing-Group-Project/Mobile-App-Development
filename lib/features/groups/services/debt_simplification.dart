import '../models/expense_model.dart';

class Settlement {
  final String from;
  final String fromName;
  final String to;
  final String toName;
  final double amount;

  Settlement({
    required this.from,
    required this.fromName,
    required this.to,
    required this.toName,
    required this.amount,
  });
}

/// Simplify debts for a group based on all expenses.
/// Returns a list of settlements {from, fromName, to, toName, amount}.
List<Settlement> simplifyDebts(List<SharedExpense> expenses) {
  // Step 1: Compute net balances per member
  final Map<String, double> balances = {};
  final Map<String, String> names = {};

  for (final expense in expenses) {
    // Track payer
    balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.totalAmount;
    names[expense.paidBy] = expense.paidByName;

    // Track splits
    for (final split in expense.splits) {
      balances[split.uid] = (balances[split.uid] ?? 0) - split.amount;
      names[split.uid] = split.name;
    }
  }

  // Step 2: Separate creditors (positive) and debtors (negative)
  final creditors = <String, double>{};
  final debtors = <String, double>{};

  balances.forEach((uid, balance) {
    if (balance > 0.01) {
      creditors[uid] = balance;
    } else if (balance < -0.01) {
      debtors[uid] = balance;
    }
  });

  // Step 3: Greedy settlement
  final settlements = <Settlement>[];

  final creditorList = creditors.entries.toList();
  final debtorList = debtors.entries.toList();

  int i = 0, j = 0;
  while (i < creditorList.length && j < debtorList.length) {
    final creditor = creditorList[i];
    final debtor = debtorList[j];

    final amount = creditor.value < -debtor.value ? creditor.value : -debtor.value;

    settlements.add(Settlement(
      from: debtor.key,
      fromName: names[debtor.key] ?? '',
      to: creditor.key,
      toName: names[creditor.key] ?? '',
      amount: double.parse(amount.toStringAsFixed(2)),
    ));

    creditorList[i] = MapEntry(creditor.key, creditor.value - amount);
    debtorList[j] = MapEntry(debtor.key, debtor.value + amount);

    if (creditorList[i].value <= 0.01) i++;
    if (debtorList[j].value >= -0.01) j++;
  }

  return settlements;
}
