import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';
import '../services/debt_simplification.dart';
import '../providers/group_provider.dart';

class SettleUpScreen extends StatelessWidget {
  final GroupModel group;

  const SettleUpScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Settle Up — ${group.name}')),
      body: StreamBuilder<List<SharedExpense>>(
        stream: provider.expensesStream(group.id),
        builder: (context, expenseSnap) {
          if (!expenseSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<Settlement>>(
            stream: provider.settlementsStream(group.id),
            builder: (context, settlementSnap) {
              if (!settlementSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final debts = simplifyDebts(
                expenseSnap.data!,
                settlementSnap.data!,
              );

              if (debts.isEmpty) {
                final theme = Theme.of(context);
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 56, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text('All settled up!',
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary)),
                      const SizedBox(height: 4),
                      Text('No outstanding debts in this group.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: debts.length,
                itemBuilder: (context, index) {
                  final d = debts[index];
                  return _DebtCard(group: group, debt: d);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final GroupModel group;
  final DebtSettlement debt;

  const _DebtCard({required this.group, required this.debt});

  Future<void> _settle(BuildContext context) async {
    final provider = context.read<GroupProvider>();
    final currentUid = provider.uid;

    if (currentUid != debt.from) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only the debtor can record this payment.')),
      );
      return;
    }

    final amountCtrl = TextEditingController(
        text: debt.amount.toStringAsFixed(0));

    final enteredAmount = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Payment'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount',
            prefix: const Text('LKR ', style: TextStyle(fontSize: 14)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amt = double.tryParse(amountCtrl.text) ?? debt.amount;
              Navigator.pop(context, amt.clamp(0, debt.amount));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    amountCtrl.dispose();
    if (enteredAmount == null || enteredAmount <= 0) return;

    final settlement = Settlement(
      id: '',
      groupId: group.id,
      fromUid: debt.from,
      fromName: debt.fromName,
      toUid: debt.to,
      toName: debt.toName,
      amount: enteredAmount,
      createdAt: DateTime.now(),
      isPartial: enteredAmount < debt.amount,
    );

    await provider.recordSettlement(settlement);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enteredAmount < debt.amount
                ? 'Partial payment of LKR ${enteredAmount.toStringAsFixed(0)} recorded.'
                : 'Full payment of LKR ${enteredAmount.toStringAsFixed(0)} recorded.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = context.read<GroupProvider>().uid == debt.from;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 20, color: theme.colorScheme.onErrorContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${debt.fromName} → ${debt.toName}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'LKR ${debt.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isMe)
              FilledButton(
                onPressed: () => _settle(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text('Settle'),
              ),
          ],
        ),
      ),
    );
  }
}
