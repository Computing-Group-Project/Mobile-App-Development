import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_model.dart';
import '../models/settlement_model.dart';
import '../providers/group_provider.dart';

class SettlementHistoryScreen extends StatelessWidget {
  final GroupModel group;

  const SettlementHistoryScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroupProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settlement History - ${group.name}'),
      ),
      body: StreamBuilder<List<Settlement>>(
        stream: provider.settlementsStream(group.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final settlements = snapshot.data!;
          if (settlements.isEmpty) {
            return const Center(child: Text('No settlements recorded yet.'));
          }

          return ListView.builder(
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final s = settlements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    Icons.receipt_long,
                    color: s.isPartial ? Colors.orange : Colors.green,
                  ),
                  title: Text('${s.fromName} → ${s.toName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: \$${s.amount.toStringAsFixed(2)}'),
                      Text('Date: ${s.createdAt.toLocal()}'),
                    ],
                  ),
                  trailing: Text(
                    s.isPartial ? 'Partial' : 'Full',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: s.isPartial ? Colors.orange : Colors.green,
                    ),
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
