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
          final theme = Theme.of(context);

          if (settlements.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded, size: 56,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('No settlements yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: settlements.length,
            itemBuilder: (context, index) {
              final s = settlements[index];
              final color = s.isPartial
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.primary;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.receipt_long, color: color),
                  title: Text('${s.fromName} → ${s.toName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LKR ${s.amount.toStringAsFixed(0)}'),
                      Text(s.createdAt.toLocal().toString().substring(0, 10),
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  trailing: Text(
                    s.isPartial ? 'Partial' : 'Full',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
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
