import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }

    // Future:
    // FirebaseCrashlytics.instance.recordError(...)
  }
}
