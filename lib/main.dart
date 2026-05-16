import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:art_mobile/app.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/services/security_service.dart';
import 'package:art_mobile/core/services/notification_service.dart';
import 'package:art_mobile/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('CRITICAL: Firebase initialization failed: $e');
    debugPrint('If running on Web, ensure you have configured Firebase correctly.');
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('NotificationService initialization failed: $e');
  }

  // Initialize core services
  await setupServiceLocator();
  
  // Initialize Security measures
  await SecurityService().init();

  runApp(const LearningApp());
}
