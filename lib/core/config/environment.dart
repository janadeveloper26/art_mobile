enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment env = Environment.development;

  // API Base URLs
  static const String devBaseUrl = 'https://xh48v3q5-8000.inc1.devtunnels.ms/api/';
  static const String stagingBaseUrl = 'https://api-staging.learningapp.local';
  static const String prodBaseUrl = 'https://api.learningapp.com';

  static String get baseUrl {
    switch (env) {
      case Environment.development:
        return devBaseUrl;
      case Environment.staging:
        return stagingBaseUrl;
      case Environment.production:
        return prodBaseUrl;
    }
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Video Streaming
  static const int videoBufferDuration = 5; // seconds
  static const int maxConcurrentVideoQualities = 1;
}
