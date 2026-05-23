import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:art_mobile/core/storage/secure_storage_service.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SecureStorageService _secureStorage;

  FcmService(this._secureStorage);

  Future<void> init() async {
    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      await _setupToken();
      _setupListeners();
    }
  }

  Future<void> _setupToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        await _updateTokenOnBackend(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _updateTokenOnBackend(newToken);
      });
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
  }

  Future<void> _updateTokenOnBackend(String token) async {
    // In a real app, send this to the Django backend
    // Since we also attach it to the device payload in auth requests, we just store it temporarily
    await _secureStorage.saveDeviceSessionId('fcm_$token'); // Or a specific method for FCM token
    debugPrint('FCM Token updated: $token');
  }

  void _setupListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
      
      // Handle approval events if needed
      if (message.data['type'] == 'approval_event') {
        // Broadcast or handle approval
      }
    });
  }
}
