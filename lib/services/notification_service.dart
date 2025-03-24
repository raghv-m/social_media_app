import '../config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _localNotifications.initialize(initSettings);

      // Request permission for notifications
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final String? token = await _messaging.getToken();
        if (token != null) {
          await _updateUserToken(token);
        }

        // Handle token refresh
        _messaging.onTokenRefresh.listen(_updateUserToken);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      }
    } catch (e) {
      throw Exception('Failed to initialize notifications: $e');
    }
  }

  // Update user's FCM token
  Future<void> _updateUserToken(String token) async {
    try {
      final String? userId = _getCurrentUserId();
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update user token: $e');
    }
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      // Show local notification
      await _showLocalNotification(message);
      
      // Store notification in Firestore
      await _storeNotification(message);
    } catch (e) {
      throw Exception('Failed to handle foreground message: $e');
    }
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    try {
      // Store notification in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': message.data['userId'],
        'type': message.data['type'],
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to handle background message: $e');
    }
  }

  // Handle notification taps
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    try {
      // Mark notification as read
      await _markNotificationAsRead(message.data['notificationId']);

      // Navigate to appropriate screen based on notification type
      _navigateToScreen(message.data);
    } catch (e) {
      throw Exception('Failed to handle notification tap: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'chattr_notifications',
        'Chattr Notifications',
        channelDescription: 'Notifications for Chattr app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
        color: const Color(0xFF2196F3),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: const BigTextStyleInformation(''),
      );

      final DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        details,
        payload: message.data.toString(),
      );
    } catch (e) {
      throw Exception('Failed to show local notification: $e');
    }
  }

  // Store notification in Firestore
  Future<void> _storeNotification(RemoteMessage message) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': message.data['userId'],
        'type': message.data['type'],
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to store notification: $e');
    }
  }

  // Mark notification as read
  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Navigate to appropriate screen
  void _navigateToScreen(Map<String, dynamic> data) {
    // This would integrate with your navigation system
    // For now, we'll just print the navigation intent
    print('Navigate to screen: ${data['screen']}');
  }

  // Get current user ID
  String? _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Send notification to user
  Future<void> sendNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      final Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      final String? fcmToken = userData?['fcmToken'];

      if (fcmToken != null) {
        // Send notification using Firebase Cloud Functions
        await _firestore.collection('notification_requests').add({
          'userId': userId,
          'fcmToken': fcmToken,
          'type': type,
          'title': title,
          'body': body,
          'data': data ?? {},
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  // Get user's notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return notificationsSnapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user notifications: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in notificationsSnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return notificationsSnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread notification count: $e');
    }
  }

  // Subscribe to notification topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  // Unsubscribe from notification topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      return await _messaging.getNotificationSettings();
    } catch (e) {
      throw Exception('Failed to get notification settings: $e');
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    required bool alert,
    required bool badge,
    required bool sound,
  }) async {
    try {
      await _messaging.requestPermission(
        alert: alert,
        badge: badge,
        sound: sound,
      );
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }
}

// This needs to be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background handlers
  await Firebase.initializeApp();
  // Handle background message
  print('Handling background message: ${message.messageId}');
} 