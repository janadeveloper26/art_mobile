import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    debugPrint('🔔 NotificationService: Init (Stubbed for stability)');
    // Commented out to prevent build errors during development
    /*
    if (kIsWeb) return;
    await _fcm.requestPermission();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: DarwinInitializationSettings());
    await (_localNotifications as dynamic).initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) => _showLocalNotification(message));
    */
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    debugPrint('🔔 NotificationService: Show (Stubbed)');
    /*
    if (kIsWeb) return;
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'main_channel', 'Main Channel', 
      importance: Importance.max, priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await (_localNotifications as dynamic).show(
      id: message.hashCode, 
      title: message.notification?.title, 
      body: message.notification?.body, 
      notificationDetails: details,
    );
    */
  }
}
