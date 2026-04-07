import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../providers/group_provider.dart';
import '../widgets/expense_tile.dart';
import '../widgets/group_activity_feed.dart';

class GroupDashboardScreen extends StatelessWidget {
  final GroupModel group;

  const GroupDashboardScreen({super.key, required this.group});

  Future<void> _confirmLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Leave "${group.name}"? You will no longer see this group.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<GroupProvider>().leaveGroup(group.id);
    if (context.mounted) context.pop();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Delete "${group.name}" and all its expenses? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<GroupProvider>().deleteGroup(group.id);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isCreator = group.createdBy == currentUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') _confirmLeave(context);
              if (value == 'delete') _confirmDelete(context);
              if (value == 'history') context.push('/settlement-history', extra: group);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'history', child: Row(
                children: [
                  Icon(Icons.history_rounded),
                  SizedBox(width: 10),
                  Text('Settlement History'),
                ],
              )),
              const PopupMenuItem(value: 'leave', child: Row(
                children: [
                  Icon(Icons.exit_to_app_rounded),
                  SizedBox(width: 10),
                  Text('Leave Group'),
                ],
              )),
              if (isCreator)
                PopupMenuItem(value: 'delete', child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 10),
                    Text('Delete Group', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                )),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Expenses'),
                Tab(text: 'Activity'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Expenses view
                  StreamBuilder(
                    stream: provider.expensesStream(group.id),
                    builder: (context, s) {
                      if (!s.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final expenses = s.data!;
                      final theme = Theme.of(context);
                      final currency = NumberFormat.currency(
                        locale: 'en_LK',
                        symbol: 'LKR ',
                        decimalDigits: 0,
                      );
                      final total = expenses.fold(
                          0.0, (sum, e) => sum + e.totalAmount);

                      if (expenses.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 56,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text('No expenses yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text('Tap + to add the first expense',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Total Expenses',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant)),
                                        const SizedBox(height: 4),
                                        Text(currency.format(total),
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  theme.colorScheme.primary,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${expenses.length} expenses',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${group.members.length} members',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant)),
                                      const SizedBox(height: 8),
                                      FilledButton.tonal(
                                        onPressed: () => context.push('/settle-up', extra: group),
                                        child: const Text('Settle Up'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...expenses.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ExpenseTile(expense: e),
                              )),
                        ],
                      );
                    },
                  ),

                  //Activity Feed view
                  GroupActivityFeed(group: group),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-expense', extra: group),
        child: const Icon(Icons.add),
      ),
    );
  }
}
