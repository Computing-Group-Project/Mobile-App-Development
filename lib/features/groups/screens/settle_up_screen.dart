import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart' as firestore_model;
import '../services/debt_simplification.dart' as algo;
import '../providers/group_provider.dart';

class SettleUpScreen extends StatelessWidget {
  final GroupModel group;

  const SettleUpScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settle Up - ${group.name}'),
      ),
      body: StreamBuilder<List<SharedExpense>>(
        stream: provider.expensesStream(group.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!;
          final settlements = algo.simplifyDebts(expenses); // ✅ use algo alias

          if (settlements.isEmpty) {
            return const Center(child: Text('All debts are settled 🎉'));
          }

          return ListView.builder(
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final s = settlements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${s.fromName} owes ${s.toName}'),
                  subtitle: Text('\$${s.amount.toStringAsFixed(2)}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final currentUid = provider.uid;
                      if (currentUid != s.from) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Only the debtor can settle this payment.')),
                        );
                        return;
                      }

                      // ✅ Use Firestore Settlement model when saving
                      final settlement = firestore_model.Settlement(
                        id: '', // Firestore will generate
                        groupId: group.id,
                        fromUid: s.from,
                        fromName: s.fromName,
                        toUid: s.to,
                        toName: s.toName,
                        amount: s.amount,
                        createdAt: DateTime.now(),
                        isPartial: false,
                      );

                      await provider.recordSettlement(settlement);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment recorded: ${s.amount.toStringAsFixed(2)}')),
                        );
                      }
                    },
                    child: const Text('Settle'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
