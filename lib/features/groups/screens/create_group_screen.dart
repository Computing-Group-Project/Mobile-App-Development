import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/group_provider.dart';
import '../models/group_model.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final List<GroupMember> members = [];

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser!;
    members.add(GroupMember(uid: u.uid, name: "You", email: ""));
  }

  void addMember() {
    if (emailCtrl.text.isEmpty) return;
    setState(() {
      members.add(GroupMember(
        uid: DateTime.now().toString(),
        name: emailCtrl.text,
        email: emailCtrl.text,
      ));
      emailCtrl.clear();
    });
  }

  Future<void> create() async {
    await context.read<GroupProvider>().createGroup(nameCtrl.text, members);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Group Name")),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Member Email"))),
                IconButton(onPressed: addMember, icon: const Icon(Icons.add))
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              children: members.map((m) => Chip(label: Text(m.name))).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: create, child: const Text("Create")),
            )
          ],
        ),
      ),
    );
  }
}