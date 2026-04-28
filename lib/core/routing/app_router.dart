import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) =>
            const Placeholder(), // Replace with LoginPage
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) =>
            const Placeholder(), // Replace with SignupPage
      ),

      // Home Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) =>
            const Placeholder(), // Replace with HomePage
      ),

      // Courses Routes
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) =>
            const Placeholder(), // Replace with CoursesPage
        routes: [
          GoRoute(
            path: ':courseId',
            name: 'course-detail',
            builder: (context, state) {
              final courseId = state.pathParameters['courseId'];
              return const Placeholder(); // Replace with CourseDetailPage
            },
          ),
        ],
      ),

      // Video Player Routes
      GoRoute(
        path: '/video/:videoId',
        name: 'video-player',
        builder: (context, state) {
          final videoId = state.pathParameters['videoId'];
          return const Placeholder(); // Replace with VideoPlayerPage
        },
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) =>
            const Placeholder(), // Replace with ProfilePage
      ),

      // Subscriptions Routes
      GoRoute(
        path: '/subscriptions',
        name: 'subscriptions',
        builder: (context, state) =>
            const Placeholder(), // Replace with SubscriptionsPage
      ),

      // Notifications Routes
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) =>
            const Placeholder(), // Replace with NotificationsPage
      ),

      // Activity Routes
      GoRoute(
        path: '/activity',
        name: 'activity',
        builder: (context, state) =>
            const Placeholder(), // Replace with ActivityPage
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) =>
            const Placeholder(), // Replace with AdminDashboard
        routes: [
          GoRoute(
            path: 'users',
            name: 'admin-users',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: 'videos',
            name: 'admin-videos',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: 'courses',
            name: 'admin-courses',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page not found'))),
  );
}
