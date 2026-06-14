class AppConstants {
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String profileEndpoint = '/profile';
  static const String coursesEndpoint = '/courses';
  static const String videosEndpoint = '/videos';
  static const String enrollmentsEndpoint = '/enrollments';
  static const String certificatesEndpoint = '/certificates';
  static const String notificationsEndpoint = '/notifications';

  // Cache Keys
  static const String userCacheKey = 'user_cache';
  static const String coursesCacheKey = 'courses_cache';
  static const String videosCacheKey = 'videos_cache';
  static const String userPreferencesCacheKey = 'user_preferences';

  // Secure Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';

  // UI Constants
  static const int itemsPerPage = 10;
  static const int debounceMilliseconds = 500;
  static const int retryAttempts = 3;
  static const int cacheExpirationHours = 24;

  // Video Player
  static const int videoQualityHD = 720;
  static const int videoQualitySD = 480;
}
