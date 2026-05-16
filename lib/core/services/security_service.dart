import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screen_protector/screen_protector.dart';

/// [SecurityService] handles application-level security features such as
/// blocking screenshots and screen recording to protect premium content.
/// Now using screen_protector for both platforms to ensure compatibility with 
/// modern Android Gradle versions.
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  /// Initialize security measures.
  Future<void> init() async {
    await protectApp();
  }

  /// Enables screenshot and screen recording protection.
  Future<void> protectApp() async {
    if (kIsWeb) return;
    try {
      // ScreenProtector provides cross-platform support for FLAG_SECURE on Android
      // and screenshot detection/prevention on iOS.
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      // Log error if security measures fail to initialize
      print('Security measures failed: $e');
    }
  }

  /// Disable protection
  Future<void> disableProtection() async {
    if (kIsWeb) return;
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      print('Failed to disable security measures: $e');
    }
  }
}
