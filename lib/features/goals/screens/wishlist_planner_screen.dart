import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/wishlist_item.dart';
import '../providers/goals_provider.dart';

class WishlistPlannerScreen extends StatefulWidget {
  const WishlistPlannerScreen({super.key});

  @override
  State<WishlistPlannerScreen> createState() => _WishlistPlannerScreenState();
}

class _WishlistPlannerScreenState extends State<WishlistPlannerScreen> {
  late final TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController();
    Future.microtask(() async {
      final provider = context.read<GoalsProvider>();
      await provider.loadAll();
      if (mounted) {
        _budgetController.text =
            provider.monthlyWishlistBudget.toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'LKR ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist Planner')),
      body: Consumer<GoalsProvider>(
        builder: (context, provider, _) {
          final items = provider.wishlist;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly savings budget',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          prefix: Text('LKR ', style: TextStyle(fontSize: 14)),
                          hintText: 'Amount available each month',
                        ),
                        onSubmitted: (_) => _applyBudget(provider),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => _applyBudget(provider),
                          child: const Text('Update budget'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final item in items) ...[
                _WishlistItemCard(
                  item: item,
                  currency: currency,
                  monthsToAfford: provider.monthsToAfford(item),
                  monthlyBudget: provider.monthlyWishlistBudget,
                  onAddSaving: () => _showAddSavingDialog(context, item),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }

  void _applyBudget(GoalsProvider provider) {
    final amount = double.tryParse(_budgetController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid monthly budget.')),
      );
      return;
    }

    provider.updateMonthlyWishlistBudget(amount);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Monthly budget updated.')));
  }

  Future<void> _showAddSavingDialog(
    BuildContext context,
    WishlistItem item,
  ) async {
    final amountController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add savings: ${item.name}'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefix: Text('LKR ', style: TextStyle(fontSize: 14)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid amount.')),
                  );
                  return;
                }

                context.read<GoalsProvider>().logWishlistSaving(
                  itemId: item.id,
                  amount: amount,
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    amountController.dispose();
  }
}

class _WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final NumberFormat currency;
  final int monthsToAfford;
  final double monthlyBudget;
  final VoidCallback onAddSaving;

  const _WishlistItemCard({
    required this.item,
    required this.currency,
    required this.monthsToAfford,
    required this.monthlyBudget,
    required this.onAddSaving,
  });

  @override
  Widget build(BuildContext context) {
    final affordableDate = monthsToAfford > 0
        ? _addMonths(DateTime.now(), monthsToAfford)
        : DateTime.now();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _PriorityChip(priority: item.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${currency.format(item.savedAmount)} / ${currency.format(item.targetPrice)}',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: item.progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 10),
            Text(
              'Months to afford: ${_formatMonths(monthsToAfford)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _buildFormulaText(item, monthlyBudget, monthsToAfford),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (monthsToAfford > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Estimated affordable date: ${DateFormat('MMM yyyy').format(affordableDate)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onAddSaving,
                icon: const Icon(Icons.savings_outlined),
                label: const Text('Log savings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonths(int months) {
    if (months <= 0) {
      return 'Already affordable';
    }
    if (months == 1) {
      return '1 month';
    }
    return '$months months';
  }

  String _buildFormulaText(
    WishlistItem item,
    double monthlyBudget,
    int months,
  ) {
    if (months <= 0) {
      return 'Formula: remaining amount is zero.';
    }

    final remaining = item.remainingAmount;
    final roundedRemaining = remaining.toStringAsFixed(0);
    final roundedBudget = monthlyBudget.toStringAsFixed(0);
    return 'Formula: ceil($roundedRemaining / $roundedBudget) = $months';
  }

  DateTime _addMonths(DateTime from, int months) {
    return DateTime(from.year, from.month + months, from.day);
  }
}

class _PriorityChip extends StatelessWidget {
  final WishlistPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      WishlistPriority.low => ('Low', Colors.blueGrey),
      WishlistPriority.medium => ('Medium', Colors.orange),
      WishlistPriority.high => ('High', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
