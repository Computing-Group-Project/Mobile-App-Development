import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';
import '../providers/group_provider.dart';

class GroupActivityFeed extends StatelessWidget {
  final GroupModel group;

  const GroupActivityFeed({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context, listen: false);

    return StreamBuilder<List<SharedExpense>>(
      stream: provider.expensesStream(group.id),
      builder: (context, expenseSnap) {
        return StreamBuilder<List<Settlement>>(
          stream: provider.settlementsStream(group.id),
          builder: (context, settlementSnap) {
            if (!expenseSnap.hasData || !settlementSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final expenses = expenseSnap.data!;
            final settlements = settlementSnap.data!;

            // Merge into one list of activity items
            final activities = <_ActivityItem>[];

            for (var e in expenses) {
              activities.add(_ActivityItem(
                createdAt: e.createdAt,
                description:
                '${e.paidByName} added expense "${e.title}" (\$${e.totalAmount.toStringAsFixed(2)})',
                icon: Icons.shopping_cart,
                color: Colors.blue,
              ));
            }

            for (var s in settlements) {
              activities.add(_ActivityItem(
                createdAt: s.createdAt,
                description:
                '${s.fromName} settled \$${s.amount.toStringAsFixed(2)} to ${s.toName}',
                icon: Icons.receipt_long,
                color: s.isPartial ? Colors.orange : Colors.green,
              ));
            }

            // Sort by date descending
            activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            if (activities.isEmpty) {
              return const Center(child: Text('No activity yet.'));
            }

            return ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final item = activities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(item.icon, color: item.color),
                    title: Text(item.description),
                    subtitle: Text(item.createdAt.toLocal().toString()),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ActivityItem {
  final DateTime createdAt;
  final String description;
  final IconData icon;
  final Color color;

  _ActivityItem({
    required this.createdAt,
    required this.description,
    required this.icon,
    required this.color,
  });
}
