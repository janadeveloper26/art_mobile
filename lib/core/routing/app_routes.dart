import 'package:flutter/material.dart';

import 'package:art_mobile/features/onboarding/onboarding_screen.dart';
import 'package:art_mobile/features/splash/splash_screen.dart';
import 'package:art_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:art_mobile/features/auth/presentation/pages/sign_up_page.dart';
import 'package:art_mobile/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:art_mobile/features/auth/presentation/pages/device_pending_approval_page.dart';
import 'package:art_mobile/features/courses/presentation/pages/courses_page.dart';
import 'package:art_mobile/features/home/home_page.dart';
import 'package:art_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:art_mobile/features/video_player/presentation/pages/video_player_page.dart';
import 'package:art_mobile/features/subscription/presentation/pages/subscription_page.dart';
import 'package:art_mobile/features/courses/presentation/pages/course_detail_page.dart';
import 'package:art_mobile/features/welcome/presentation/pages/welcome_screen.dart';
import 'package:art_mobile/features/supply/presentation/pages/supply_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String skillSelection = '/skill-selection';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String verifyOtp = '/verify-otp';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String notifications = '/notifications';
  static const String videoPlayer = '/video-player';
  static const String subscription = '/subscription';
  static const String courseDetail = '/course-detail';
  static const String devicePendingApproval = '/device-pending-approval';
  static const String supply = '/supply';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case skillSelection:
        return MaterialPageRoute(builder: (_) => LoginPage()); // Placeholder for now
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case verifyOtp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => VerifyOtpPage(
            phoneNumber: args?['phoneNumber'] ?? '',
            verificationId: args?['verificationId'] ?? '',
          ),
        );
      case devicePendingApproval:
        return MaterialPageRoute(builder: (_) => const DevicePendingApprovalPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case courses:
        return MaterialPageRoute(builder: (_) => const CoursesPage());
      case notifications:
        return MaterialPageRoute(builder: (_) => NotificationsPage());
      case videoPlayer:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => VideoPlayerPage(
            courseId: args?['courseId'] ?? '1',
            videoId: args?['videoId'] ?? '0',
            videoUrl: args?['videoUrl'],
          ),
        );
      case subscription:
        return MaterialPageRoute(builder: (_) => const SubscriptionPage());
      case courseDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CourseDetailPage(
            courseId: args?['courseId'] ?? '1',
          ),
        );
      case supply:
        return MaterialPageRoute(builder: (_) => const SupplyPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
