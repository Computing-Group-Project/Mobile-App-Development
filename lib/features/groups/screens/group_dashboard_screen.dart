import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../providers/group_provider.dart';
import 'add_shared_expense_screen.dart';
import '../widgets/expense_tile.dart';

class GroupDashboardScreen extends StatelessWidget {
  final GroupModel group;

  const GroupDashboardScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: StreamBuilder(
        stream: provider.expensesStream(group.id),
        builder: (_, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final expenses = s.data!;
          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Text("Total: \$${group.totalExpenses}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...expenses.map((e) => ExpenseTile(expense: e))
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddSharedExpenseScreen(group: group)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}