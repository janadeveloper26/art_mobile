import 'package:flutter/material.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/config/service_locator.dart';

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sl<ThemeManager>(),
      builder: (context, _) {
        final themeManager = sl<ThemeManager>();
        return MaterialApp(
          title: 'ART-Mobile',
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
