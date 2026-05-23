import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:art_mobile/app.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/services/security_service.dart';
import 'package:art_mobile/core/services/notification_service.dart';
import 'package:art_mobile/core/services/fcm_service.dart';
import 'package:art_mobile/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    if (!kIsWeb) {
      await googleSignIn.attemptLightweightAuthentication();
    }

    debugPrint('Firebase initialized');
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  await setupServiceLocator();

  try {
    await sl<FcmService>().init();
  } catch (e) {
    debugPrint('FCM init failed: $e');
  }

  await SecurityService().init();

  runApp(const LearningApp());
}
