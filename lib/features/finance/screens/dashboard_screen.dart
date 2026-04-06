import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../../../features/settings/providers/theme_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FundFlow'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isDark = themeProvider.themeMode == ThemeMode.dark ||
                  (themeProvider.themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                tooltip: isDark ? 'Light mode' : 'Dark mode',
                onPressed: () => themeProvider.setThemeMode(isDark ? 'light' : 'dark'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance overview card
            StreamBuilder<List<Transaction>>(
              stream: context
                  .read<TransactionProvider>()
                  .transactionsStream,
              builder: (context, snapshot) {
                final txns = snapshot.data ?? [];
                final currency = NumberFormat.currency(
                  locale: 'en_LK',
                  symbol: 'LKR ',
                  decimalDigits: 0,
                );
                final income = txns
                    .where((t) => t.type == 'income')
                    .fold(0.0, (s, t) => s + t.amount);
                final expense = txns
                    .where((t) => t.type == 'expense')
                    .fold(0.0, (s, t) => s + t.amount);
                final balance = income - expense;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Balance',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currency.format(balance),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _BalanceChip(
                              label: 'Income',
                              amount: currency.format(income),
                              color: Colors.green,
                              icon: Icons.north_east_rounded,
                            ),
                            const SizedBox(width: 12),
                            _BalanceChip(
                              label: 'Expenses',
                              amount: currency.format(expense),
                              color: Colors.red,
                              icon: Icons.south_east_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Quick actions
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add',
                  onTap: () {
                    context.push('/add-transaction');
                  },
                ),
                _QuickAction(
                  icon: Icons.camera_alt_outlined,
                  label: 'Scan',
                  onTap: () {
                    context.push('/scan-receipt');
                  },
                ),
                _QuickAction(
                  icon: Icons.flag_outlined,
                  label: 'Goals',
                  onTap: () {
                    context.push('/goals');
                  },
                ),
                _QuickAction(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  onTap: () {
                    context.push('/wishlist');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Planning',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/budgets'),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('Budgets'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/calendar'),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Calendar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Recent transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/transactions'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Transaction>>(
              stream: context
                  .read<TransactionProvider>()
                  .transactionsStream,
              builder: (context, snapshot) {
                final txns = (snapshot.data ?? []).take(5).toList();
                if (txns.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No transactions yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + to add your first transaction',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final currency = NumberFormat.currency(
                  locale: 'en_LK',
                  symbol: 'LKR ',
                  decimalDigits: 0,
                );
                return Card(
                  child: Column(
                    children: txns.map((t) {
                      final isIncome = t.type == 'income';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (isIncome
                                  ? Colors.green
                                  : Colors.red)
                              .withValues(alpha: 0.15),
                          child: Icon(
                            isIncome
                                ? Icons.north_east_rounded
                                : Icons.south_east_rounded,
                            color:
                                isIncome ? Colors.green : Colors.red,
                            size: 18,
                          ),
                        ),
                        title: Text(t.title),
                        subtitle: Text(t.category),
                        trailing: Text(
                          currency.format(t.amount),
                          style: TextStyle(
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _BalanceChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 6),
            Text(label, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
