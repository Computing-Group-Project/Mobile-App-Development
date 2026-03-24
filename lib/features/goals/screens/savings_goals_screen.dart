import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/savings_goal.dart';
import '../providers/goals_provider.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'LKR ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: Consumer<GoalsProvider>(
        builder: (context, provider, _) {
          final goals = provider.goals;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GoalsSummaryCard(
                totalTarget: provider.totalGoalTarget,
                totalSaved: provider.totalGoalSaved,
                currency: currency,
              ),
              const SizedBox(height: 16),
              for (final goal in goals) ...[
                _GoalCard(
                  goal: goal,
                  currency: currency,
                  onLogContribution: () =>
                      _showContributionDialog(context, goal: goal),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _showContributionDialog(
    BuildContext context, {
    required SavingsGoal goal,
  }) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Log Contribution: ${goal.title}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'LKR ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid amount.')),
                      );
                      return;
                    }

                    context.read<GoalsProvider>().logGoalContribution(
                      goalId: goal.id,
                      amount: amount,
                      date: selectedDate,
                      note: noteController.text.trim().isEmpty
                          ? null
                          : noteController.text.trim(),
                    );

                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contribution logged for ${goal.title}.'),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    noteController.dispose();
  }
}

class _GoalsSummaryCard extends StatelessWidget {
  final double totalTarget;
  final double totalSaved;
  final NumberFormat currency;

  const _GoalsSummaryCard({
    required this.totalTarget,
    required this.totalSaved,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTarget == 0
        ? 0.0
        : (totalSaved / totalTarget).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Progress Overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${currency.format(totalSaved)} of ${currency.format(totalTarget)} saved',
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final NumberFormat currency;
  final VoidCallback onLogContribution;

  const _GoalCard({
    required this.goal,
    required this.currency,
    required this.onLogContribution,
  });

  @override
  Widget build(BuildContext context) {
    final contributions = context.watch<GoalsProvider>().contributionsForGoal(
      goal.id,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  child: Icon(_goalIcon(goal.iconKey), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM dd').format(goal.targetDate),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${currency.format(goal.currentAmount)} / ${currency.format(goal.targetAmount)}',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              '${currency.format(goal.remainingAmount)} remaining',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onLogContribution,
                icon: const Icon(Icons.add),
                label: const Text('Log contribution'),
              ),
            ),
            if (contributions.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Recent contributions',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              for (final contribution in contributions.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(contribution.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        currency.format(contribution.amount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

IconData _goalIcon(String key) {
  switch (key) {
    case 'laptop':
      return Icons.laptop_mac;
    case 'shield':
      return Icons.health_and_safety;
    case 'flight':
      return Icons.flight_takeoff;
    default:
      return Icons.flag;
  }
}
