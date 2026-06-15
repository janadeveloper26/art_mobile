// =============================================================================
// ENVIRONMENT CONFIGURATION
// =============================================================================
//
// HOW TO PASS VALUES AT BUILD TIME (--dart-define):
//
//   Development (default, no flags needed):
//     flutter run
//
//   Staging:
//     flutter run --dart-define=ENV=staging --dart-define=BASE_URL=https://staging-api.gloriousartcreations.com/api/v1/
//
//   Production:
//     flutter build apk --dart-define=ENV=production --dart-define=BASE_URL=https://api.gloriousartcreations.com/api/v1/
//
//   Or store all dart-defines in a JSON file and pass them with:
//     flutter run --dart-define-from-file=env/development.json
//     flutter run --dart-define-from-file=env/production.json
//
// WHY NOT .env FILES?
//   Flutter does NOT natively read .env files at runtime like Node.js does.
//   Packages like flutter_dotenv bundle the .env file as an asset, meaning
//   the values are readable inside the APK binary — NOT secure for secrets.
//   --dart-define / --dart-define-from-file values are compiled directly into
//   the binary and are harder to extract, making them the recommended approach.
//   See: https://dart.dev/tools/dart-compile#dart-define
//
// =============================================================================

/// Available runtime environments for the app.
enum Environment {
  /// Local development — connects to local or ngrok backend. SSL bypass enabled.
  development,

  /// Staging / QA — connects to staging server. Mirrors production config.
  staging,

  /// Production — connects to live AWS backend. SSL strictly validated.
  production,
}

class EnvironmentConfig {
  // ---------------------------------------------------------------------------
  // ENVIRONMENT SELECTION
  // ---------------------------------------------------------------------------

  /// Reads the ENV dart-define at compile time.
  /// Defaults to 'development' when running `flutter run` without flags.
  static const String _envString =
      String.fromEnvironment('ENV', defaultValue: 'development');

  static Environment get env {
    switch (_envString) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.development;
    }
  }

  /// Convenience getters for conditional logic throughout the app.
  static bool get isDevelopment => env == Environment.development;
  static bool get isStaging => env == Environment.staging;
  static bool get isProduction => env == Environment.production;

  // ---------------------------------------------------------------------------
  // API BASE URL
  // ---------------------------------------------------------------------------
  //
  // Priority order:
  //   1. --dart-define=BASE_URL=<url>   (overrides everything)
  //   2. Default per environment (resolved at compile time via _envString)
  //
  // For local Android emulator:  http://10.0.2.2:8000/api/v1/
  // For local real device:       http://<your-PC-LAN-IP>:8000/api/v1/
  // ---------------------------------------------------------------------------

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  /// Internal default — compile-time constant resolved from ENV dart-define.
  /// Switch statement cannot be used in const context, so we use a chain
  /// of ternaries (also evaluated at compile time).
  static const String _defaultBaseUrl = _envString == 'production'
      ? 'https://api.gloriousartcreations.com/api/v1/'
      : _envString == 'staging'
          ? 'https://staging-api.gloriousartcreations.com/api/v1/'
          : 'http://10.0.2.2:8000/api/v1/'; // development default (emulator)

  // ---------------------------------------------------------------------------
  // CLOUDFRONT CDN (for S3 video streaming)
  // ---------------------------------------------------------------------------
  //
  // Override via: --dart-define=CLOUDFRONT_URL=https://dXXXXXXXXXXX.cloudfront.net
  // Leave as default if CloudFront URL doesn't change between environments.
  // ---------------------------------------------------------------------------

  static const String cloudFrontBaseUrl = String.fromEnvironment(
    'CLOUDFRONT_URL',
    defaultValue: 'https://d3aj7czvezt6jf.cloudfront.net',
  );

  // ---------------------------------------------------------------------------
  // RAZORPAY
  // ---------------------------------------------------------------------------
  //
  // Use TEST key for development/staging, LIVE key for production.
  // NEVER hardcode the live key here — always pass via --dart-define.
  // Override via: --dart-define=RAZORPAY_KEY=rzp_live_XXXXXXXXXXXX
  // ---------------------------------------------------------------------------

  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_XXXXXXXXXXXXXXXX', // replace with your test key
  );

  // ---------------------------------------------------------------------------
  // HTTP TIMEOUTS
  // ---------------------------------------------------------------------------
  //
  // Staging and production use tighter timeouts.
  // Development is more lenient to account for slow local servers or ngrok.
  // ---------------------------------------------------------------------------

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ---------------------------------------------------------------------------
  // SECURITY FLAGS
  // ---------------------------------------------------------------------------
  //
  // allowSelfSignedCertificates: MUST be false in production.
  // This bypasses SSL validation — only acceptable for local dev servers
  // that don't have a valid TLS cert (e.g., http://localhost or ngrok).
  // Your AWS backend (https://api.gloriousartcreations.com) has a valid cert,
  // so this should be false for staging and production.
  // ---------------------------------------------------------------------------

  static bool get allowSelfSignedCertificates => isDevelopment;

  // ---------------------------------------------------------------------------
  // LOGGING & DEBUGGING
  // ---------------------------------------------------------------------------
  //
  // enableNetworkLogs: Prints full request/response logs via pretty_dio_logger.
  // Disable in production to avoid leaking sensitive data to logcat.
  // ---------------------------------------------------------------------------

  static bool get enableNetworkLogs => !isProduction;

  /// Verbose Bloc transition logs. Disable in production builds.
  static bool get enableBlocLogs => isDevelopment;

  // ---------------------------------------------------------------------------
  // VIDEO STREAMING
  // ---------------------------------------------------------------------------

  /// Number of seconds to buffer before playback starts.
  static const int videoBufferSeconds = 5;

  /// Max simultaneous video quality tracks to load (keep at 1 for bandwidth).
  static const int maxConcurrentVideoQualities = 1;

  // ---------------------------------------------------------------------------
  // APP METADATA (read-only, set at build time via package_info_plus)
  // ---------------------------------------------------------------------------
  //
  // Application version and build number are read from pubspec.yaml
  // at runtime using package_info_plus — no need to hardcode them here.
  // ---------------------------------------------------------------------------
}
