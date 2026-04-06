import '../models/expense_model.dart';
import '../models/settlement_model.dart';

class DebtSettlement {
  final String from;
  final String fromName;
  final String to;
  final String toName;
  final double amount;

  DebtSettlement({
    required this.from,
    required this.fromName,
    required this.to,
    required this.toName,
    required this.amount,
  });
}

/// Simplify debts for a group based on all expenses and recorded settlements.
/// Returns a list of outstanding debts after accounting for payments already made.
List<DebtSettlement> simplifyDebts(
  List<SharedExpense> expenses,
  List<Settlement> settlements,
) {
  // Step 1: Compute net balances per member from expenses
  final Map<String, double> balances = {};
  final Map<String, String> names = {};

  for (final expense in expenses) {
    balances[expense.paidBy] = (balances[expense.paidBy] ?? 0) + expense.totalAmount;
    names[expense.paidBy] = expense.paidByName;

    for (final split in expense.splits) {
      balances[split.uid] = (balances[split.uid] ?? 0) - split.amount;
      names[split.uid] = split.name;
    }
  }

  // Step 2: Apply recorded settlements to reduce outstanding balances
  for (final s in settlements) {
    // Debtor paid — their negative balance goes up
    balances[s.fromUid] = (balances[s.fromUid] ?? 0) + s.amount;
    if (s.fromName.isNotEmpty) names[s.fromUid] = s.fromName;
    // Creditor received — their positive balance goes down
    balances[s.toUid] = (balances[s.toUid] ?? 0) - s.amount;
    if (s.toName.isNotEmpty) names[s.toUid] = s.toName;
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
  final result = <DebtSettlement>[];

  final creditorList = creditors.entries.toList();
  final debtorList = debtors.entries.toList();

  int i = 0, j = 0;
  while (i < creditorList.length && j < debtorList.length) {
    final creditor = creditorList[i];
    final debtor = debtorList[j];

    final amount = creditor.value < -debtor.value ? creditor.value : -debtor.value;

    result.add(DebtSettlement(
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

  return result;
}
