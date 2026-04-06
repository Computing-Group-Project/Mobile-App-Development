import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'all'; // all | income | expense
  String _search = '';

  static const _months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  List<Transaction> _applyFilters(List<Transaction> txns) {
    return txns.where((t) {
      final matchesType = _filter == 'all' || t.type == _filter;
      final matchesSearch = _search.isEmpty ||
          t.title.toLowerCase().contains(_search.toLowerCase()) ||
          t.category.toLowerCase().contains(_search.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  /// Groups transactions by "MMM yyyy" label, preserving sort order.
  Map<String, List<Transaction>> _groupByMonth(List<Transaction> txns) {
    final map = <String, List<Transaction>>{};
    for (final t in txns) {
      final key = '${_months[t.date.month]} ${t.date.year}';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(
      locale: 'en_LK',
      symbol: 'LKR ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-transaction'),
          ),
        ],
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: context.read<TransactionProvider>().transactionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snapshot.data ?? [];
          final filtered = _applyFilters(all);
          final grouped = _groupByMonth(filtered);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Income',
                      selected: _filter == 'income',
                      onTap: () => setState(() => _filter = 'income'),
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Expenses',
                      selected: _filter == 'expense',
                      onTap: () => setState(() => _filter = 'expense'),
                      color: Colors.red,
                    ),
                    const Spacer(),
                    Text(
                      '${filtered.length} transactions',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Transaction list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No transactions found',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: grouped.length,
                        itemBuilder: (context, index) {
                          final month = grouped.keys.elementAt(index);
                          final txns = grouped[month]!;

                          // Monthly summary
                          final monthIncome = txns
                              .where((t) => t.type == 'income')
                              .fold(0.0, (s, t) => s + t.amount);
                          final monthExpense = txns
                              .where((t) => t.type == 'expense')
                              .fold(0.0, (s, t) => s + t.amount);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Text(
                                      month,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_filter != 'expense')
                                      Text(
                                        '+${currency.format(monthIncome)}',
                                        style:
                                            theme.textTheme.labelSmall?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (_filter == 'all')
                                      const SizedBox(width: 8),
                                    if (_filter != 'income')
                                      Text(
                                        '-${currency.format(monthExpense)}',
                                        style:
                                            theme.textTheme.labelSmall?.copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Card(
                                margin: EdgeInsets.zero,
                                child: Column(
                                  children: txns.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final t = entry.value;
                                    final isIncome = t.type == 'income';
                                    return Column(
                                      children: [
                                        Dismissible(
                                          key: Key(t.id),
                                          direction:
                                              DismissDirection.endToStart,
                                          background: Container(
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.only(
                                                right: 16),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(
                                                  alpha: 0.15),
                                              borderRadius: i == 0 &&
                                                      txns.length == 1
                                                  ? BorderRadius.circular(12)
                                                  : i == 0
                                                      ? const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              12))
                                                      : i == txns.length - 1
                                                          ? const BorderRadius
                                                              .vertical(
                                                              bottom:
                                                                  Radius.circular(
                                                                      12))
                                                          : BorderRadius.zero,
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                          confirmDismiss: (_) async {
                                            return await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                    'Delete transaction?'),
                                                content: Text(
                                                    'Remove "${t.title}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, false),
                                                    child:
                                                        const Text('Cancel'),
                                                  ),
                                                  FilledButton(
                                                    style: FilledButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, true),
                                                    child:
                                                        const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          onDismissed: (_) {
                                            context
                                                .read<TransactionProvider>()
                                                .removeTransaction(t.id);
                                          },
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  (isIncome
                                                          ? Colors.green
                                                          : Colors.red)
                                                      .withValues(alpha: 0.15),
                                              child: Icon(
                                                isIncome
                                                    ? Icons
                                                        .north_east_rounded
                                                    : Icons
                                                        .south_east_rounded,
                                                color: isIncome
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 18,
                                              ),
                                            ),
                                            title: Text(t.title),
                                            subtitle: Text(
                                              '${t.category}  ·  ${DateFormat('MMM d').format(t.date)}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            trailing: Text(
                                              '${isIncome ? '+' : '-'}${currency.format(t.amount)}',
                                              style: TextStyle(
                                                color: isIncome
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (i < txns.length - 1)
                                          Divider(
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16,
                                            color: theme.colorScheme.outline
                                                .withValues(alpha: 0.2),
                                          ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? activeColor
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? activeColor : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
