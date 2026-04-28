import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:art_mobile/app.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/services/security_service.dart';
import 'package:art_mobile/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await NotificationService().init();
  } catch (e) {
    debugPrint('Service initialization failed: $e');
  }

  // Initialize core services
  await setupServiceLocator();
  
  // Initialize Security measures
  await SecurityService().init();

  runApp(const LearningApp());
}
