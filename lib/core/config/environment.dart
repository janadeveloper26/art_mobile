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
  static const String baseUrl = String.fromEnvironment('BASE_URL',
      // defaultValue: 'https://api.gloriousartcreations.com/api/v1/',
      defaultValue: 'http://127.0.0.1:8000/api/v1/');

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Video Streaming
  static const int videoBufferDuration = 5; // seconds
  static const int maxConcurrentVideoQualities = 1;
}
