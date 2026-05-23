import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;

class DeviceService {
  static const String _installIdKey = 'install_id';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _installId;
  
  Future<void> init() async {
    _installId = await _storage.read(key: _installIdKey);
    if (_installId == null) {
      _installId = const Uuid().v4();
      await _storage.write(key: _installIdKey, value: _installId!);
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_installId == null) await init();
    
    String platformName = 'web';
    String model = 'Browser';
    String osVersion = 'Unknown';
    String manufacturer = 'Unknown';
    String brand = 'Unknown';

    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      model = webInfo.browserName.toString();
      osVersion = webInfo.userAgent ?? 'Unknown';
    } else {
      platformName = Platform.isAndroid ? 'android' : 'ios';
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        model = androidInfo.model;
        osVersion = androidInfo.version.release;
        manufacturer = androidInfo.manufacturer;
        brand = androidInfo.brand;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        model = iosInfo.utsname.machine;
        osVersion = iosInfo.systemVersion;
        manufacturer = 'Apple';
        brand = 'Apple';
      }
    }

    final fcmToken = await _storage.read(key: 'device_session_id'); // We stored it here temporarily or it should be 'fcm_token'

    return {
      'device_id': _installId,
      'device_name': model,
      'manufacturer': manufacturer,
      'brand': brand,
      'android_version': osVersion,
      'platform': platformName,
      'fcm_token': fcmToken?.replaceFirst('fcm_', '') ?? '',
    };
  }
}
