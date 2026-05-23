import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceService {
  static Future<Map<String, dynamic>> getDevicePayload() async {
    final deviceInfo = DeviceInfoPlugin();

    final android = await deviceInfo.androidInfo;

    final fcmToken = await FirebaseMessaging.instance.getToken();

    return {
      'device_id': android.id,
      'device_name': android.model,
      'manufacturer': android.manufacturer,
      'brand': android.brand,
      'android_version': android.version.release,
      'platform': 'android',
      'fcm_token': fcmToken,
    };
  }
}
