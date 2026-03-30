import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../models/group_model.dart';
import 'create_group_screen.dart';
import 'group_dashboard_screen.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Groups")),
      body: StreamBuilder<List<GroupModel>>(
        stream: provider.groupsStream,
        builder: (_, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final groups = s.data!;
          if (groups.isEmpty) {
            return const Center(child: Text("No groups yet"));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (_, i) {
              final g = groups[i];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(g.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${g.members.length} members"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDashboardScreen(group: g),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}