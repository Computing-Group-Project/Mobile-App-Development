import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { budgetAlert, billReminder, groupActivity }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  factory NotificationItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      title: d['title'] as String,
      body: d['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == d['type'],
        orElse: () => NotificationType.groupActivity,
      ),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      read: d['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'type': type.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'read': read,
      };
}
