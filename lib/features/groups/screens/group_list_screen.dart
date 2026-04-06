import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../models/group_model.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: StreamBuilder<List<GroupModel>>(
        stream: provider.groupsStream,
        builder: (_, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final groups = s.data!;
          if (groups.isEmpty) {
            return const Center(child: Text('No groups yet'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (_, i) {
              final g = groups[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${g.members.length} member${g.members.length == 1 ? '' : 's'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/group-dashboard', extra: g),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-group'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
