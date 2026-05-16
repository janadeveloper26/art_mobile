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
    
    final packageInfo = await PackageInfo.fromPlatform();
    
    String platformName = 'web';
    String model = 'Browser';
    String osVersion = 'Unknown';

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
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        model = iosInfo.utsname.machine;
        osVersion = iosInfo.systemVersion;
      }
    }

    return {
      'install_id': _installId,
      'platform': platformName,
      'device_model': model,
      'os_version': osVersion,
      'app_version': packageInfo.version,
    };
  }
}
