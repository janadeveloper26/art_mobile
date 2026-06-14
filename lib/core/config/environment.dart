enum Environment { development, staging, production }

class EnvironmentConfig {
  static const String envString =
      String.fromEnvironment('ENV', defaultValue: 'development');

  static Environment get env {
    switch (envString) {
      case 'development':
        return Environment.development;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.production;
    }
  }

  // API Base URLs
  // For Android emulator, use 10.0.2.2 to reach the host machine.
  // For a real device, override BASE_URL with your PC's LAN IP, e.g. http://192.168.1.10:8000/api/v1/.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.gloriousartcreations.com/api/v1/',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);

  // CloudFront CDN — set CLOUDFRONT_URL via --dart-define in your run config.
  // Example: https://d1234example.cloudfront.net
  // Leave empty to use full URLs already stored in lesson.videoUrl.
  static const String cloudFrontBaseUrl = String.fromEnvironment(
    'CLOUDFRONT_URL',
    defaultValue: 'https://d3aj7czvezt6jf.cloudfront.net',
  );

  // Video Streaming
  static const int videoBufferDuration = 5; // seconds
  static const int maxConcurrentVideoQualities = 1;
}
