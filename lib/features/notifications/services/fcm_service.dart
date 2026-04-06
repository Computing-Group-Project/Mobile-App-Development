import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

/// Handles Firebase Cloud Messaging registration and message routing.
///
/// Group activity push notifications are triggered server-side when a new
/// expense is added to a group (via a Firestore-triggered Cloud Function that
/// fans out to all group member FCM tokens).
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {
    // Request permission (Android 13+)
    await _fcm.requestPermission();

    // Save this device's FCM token to the user's Firestore document
    await _saveToken();

    // Refresh token if it rotates
    _fcm.onTokenRefresh.listen(_updateToken);

    // Foreground messages: show a local notification
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        NotificationService().showGroupActivityNotification(
          title: notification.title ?? 'Group Update',
          body: notification.body ?? '',
        );
      }
    });
  }

  Future<void> _saveToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final token = await _fcm.getToken();
    if (token == null) return;
    await _db.collection('users').doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<void> _updateToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
  }
}
