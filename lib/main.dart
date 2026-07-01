import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:art_mobile/app.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/services/security_service.dart';
import 'package:art_mobile/core/services/notification_service.dart';
import 'package:art_mobile/core/services/fcm_service.dart';
import 'package:art_mobile/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:freerasp/freerasp.dart';
import 'dart:io';

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

    if (!kIsWeb) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    debugPrint('Firebase & Crashlytics initialized');
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

  if (!kIsWeb && !kDebugMode) {
    _initFreeRasp();
  }

  runApp(const LearningApp());
}

void _initFreeRasp() {
  final config = TalsecConfig(
    androidConfig: AndroidConfig(
      packageName: 'com.gloriousartcreations.app',
      signingCertHashes: ['YOUR_BASE64_CERT_HASH_HERE'],
    ),
    iosConfig: IOSConfig(
      bundleIds: ['com.gloriousartcreations.app'],
      teamId: 'YOUR_TEAM_ID',
    ),
    watcherMail: 'security@yourdomain.com',
    isProd: true,
  );

  final callback = ThreatCallback(
    onAppIntegrity: () => _handleThreat('App Integrity tampered'),
    onObfuscationIssues: () => _handleThreat('Obfuscation issues'),
    onDebug: () => _handleThreat('Debugging detected'),
    onDeviceBinding: () => _handleThreat('Device binding failed'),
    onDeviceID: () => _handleThreat('Device ID failed'),
    onHooks: () => _handleThreat('Hooking detected'),
    onPrivilegedAccess: () => _handleThreat('Root/Jailbreak detected'),
    onSecureHardwareNotAvailable: () => _handleThreat('Secure Hardware not available'),
    onSimulator: () => _handleThreat('Simulator/Emulator detected'),
  );

  Talsec.instance.attachListener(callback);
  Talsec.instance.start(config);
}

void _handleThreat(String threatMessage) {
  FirebaseCrashlytics.instance.recordError(Exception(threatMessage), null, fatal: true, reason: 'Security Threat Detected');
  exit(0);
}
