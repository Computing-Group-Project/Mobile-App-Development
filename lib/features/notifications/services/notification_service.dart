import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/notification_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _log(String title, String body, NotificationType type) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _db.collection('users').doc(uid).collection('notifications').add(
          NotificationItem(
            id: '',
            title: title,
            body: body,
            type: type,
            createdAt: DateTime.now(),
            read: false,
          ).toMap(),
        );
  }

  static const _budgetChannelId = 'budget_alerts';
  static const _budgetChannelName = 'Budget Alerts';
  static const _billChannelId = 'bill_reminders';
  static const _billChannelName = 'Bill Reminders';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings: initSettings);

    // Request Android 13+ notification permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Call after recording a transaction to check if the category budget
  /// has crossed the 80% threshold.
  Future<void> showBudgetAlert({
    required String category,
    required double spent,
    required double cap,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notif_budget') ?? true)) return;

    final percent = (spent / cap * 100).round();
    final title = 'Budget Alert: $category';
    final body = "You've used $percent% of your LKR ${cap.toStringAsFixed(0)} $category budget.";
    _log(title, body, NotificationType.budgetAlert);
    await _plugin.show(
      id: category.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _budgetChannelId,
          _budgetChannelName,
          channelDescription: 'Alerts when a category budget is nearly spent',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Schedule a reminder notification 1 day before [dueDate].
  Future<void> scheduleBillReminder({
    required int id,
    required String billName,
    required DateTime dueDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notif_bill') ?? true)) return;

    final reminderTime = dueDate.subtract(const Duration(days: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    _log('Bill Due Tomorrow', '$billName is due tomorrow.', NotificationType.billReminder);
    await _plugin.zonedSchedule(
      id: id,
      title: 'Bill Due Tomorrow',
      body: '$billName is due tomorrow.',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _billChannelId,
          _billChannelName,
          channelDescription: 'Reminders for upcoming bill due dates',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Show a notification for an incoming FCM group activity message.
  Future<void> showGroupActivityNotification({
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('notif_group') ?? true)) return;

    _log(title, body, NotificationType.groupActivity);
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'group_activity',
          'Group Activity',
          channelDescription: 'Push notifications for group expense activity',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
