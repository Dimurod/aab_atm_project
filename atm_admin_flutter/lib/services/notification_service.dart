// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Local notifications setup
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Firebase Messaging
    await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _showLocal(
        title: message.notification?.title ?? 'ATM Alert',
        body: message.notification?.body ?? '',
        isEscalation: message.data['event'] == 'escalation',
      );
    });

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Navigate to ticket
    });
  }

  static Future<void> _showLocal({
    required String title,
    required String body,
    bool isEscalation = false,
  }) async {
    final android = AndroidNotificationDetails(
      isEscalation ? 'escalation' : 'tickets',
      isEscalation ? 'Эскалации' : 'Заявки',
      importance: isEscalation ? Importance.max : Importance.high,
      priority: isEscalation ? Priority.max : Priority.high,
      color: isEscalation
          ? const Color(0xFFE8394A) // red
          : const Color(0xFFC8A951), // gold
    );
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: android),
    );
  }

  // Call this from WebSocket handler
  static Future<void> showEscalationAlert(String ticketNo, String user) =>
      _showLocal(
        title: '🔴 Эскалация — $ticketNo',
        body: 'Клиент $user не получил помощь',
        isEscalation: true,
      );

  static Future<void> showNewTicket(String ticketNo) => _showLocal(
        title: '📋 Новая заявка — $ticketNo',
        body: 'Требует внимания оператора',
      );
}
