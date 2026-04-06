import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Stream<List<NotificationItem>> _stream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(NotificationItem.fromDoc).toList());
  }

  Future<void> _markAllRead(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> _markRead(String uid, String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(id)
        .update({'read': true});
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return Icons.savings_outlined;
      case NotificationType.billReminder:
        return Icons.event_outlined;
      case NotificationType.groupActivity:
        return Icons.group_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [],
      ),
      floatingActionButton: StreamBuilder<List<NotificationItem>>(
        stream: _stream(),
        builder: (context, snapshot) {
          final hasUnread =
              (snapshot.data ?? []).any((n) => !n.read);
          if (!hasUnread) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _markAllRead(context),
            icon: const Icon(Icons.done_all),
            label: const Text('Mark all read'),
          );
        },
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _stream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 64,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: item.read
                      ? theme.colorScheme.surfaceContainerHigh
                      : theme.colorScheme.primaryContainer,
                  child: Icon(
                    _icon(item.type),
                    size: 20,
                    color: item.read
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        item.read ? FontWeight.normal : FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.body),
                    const SizedBox(height: 2),
                    Text(
                      _timeAgo(item.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
                onTap: item.read ? null : () => _markRead(uid, item.id),
              );
            },
          );
        },
      ),
    );
  }
}
