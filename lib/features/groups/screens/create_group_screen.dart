import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final List<GroupMember> _members = [];
  bool _lookingUp = false;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser!;
    _members.add(GroupMember(
      uid: u.uid,
      name: u.displayName ?? u.email ?? 'You',
      email: u.email ?? '',
    ));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    final email = _emailCtrl.text.trim().toLowerCase();
    if (email.isEmpty) return;

    final me = FirebaseAuth.instance.currentUser!;
    if (email == (me.email ?? '').toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("That's you — you're already in the group.")),
      );
      return;
    }

    if (_members.any((m) => m.email.toLowerCase() == email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That person is already added.')),
      );
      return;
    }

    setState(() => _lookingUp = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No account found for $email')),
        );
        return;
      }

      final data = snap.docs.first.data();
      setState(() {
        _members.add(GroupMember(
          uid: data['uid'] as String,
          name: data['name'] as String? ?? email,
          email: email,
        ));
        _emailCtrl.clear();
      });
    } finally {
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a group name.')),
      );
      return;
    }
    setState(() => _creating = true);
    try {
      await context.read<GroupProvider>().createGroup(_nameCtrl.text.trim(), _members);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                Text('Add Members', style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                )),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addMember(),
                        decoration: InputDecoration(
                          labelText: 'Member Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _lookingUp
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : IconButton.filled(
                            onPressed: _addMember,
                            icon: const Icon(Icons.person_add_rounded),
                          ),
                  ],
                ),

                const SizedBox(height: 14),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _members.map((m) {
                    final isMe = m.uid == FirebaseAuth.instance.currentUser?.uid;
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      label: Text(isMe ? 'You' : m.name),
                      deleteIcon: isMe ? null : const Icon(Icons.close, size: 16),
                      onDeleted: isMe ? null : () => setState(() => _members.remove(m)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: FilledButton(
              onPressed: _creating ? null : _create,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _creating
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create Group', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
