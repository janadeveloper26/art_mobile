import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get_it/get_it.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:art_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:art_mobile/core/storage/secure_storage_service.dart';
import 'package:art_mobile/core/network/interceptors/retry_interceptor.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/config/environment.dart';
import 'package:art_mobile/core/services/device_service.dart';
import 'package:art_mobile/core/services/fcm_service.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:flutter/foundation.dart';

// Features
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:art_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:art_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:art_mobile/features/auth/services/firebase_auth_service.dart';
import 'package:art_mobile/features/courses/domain/repositories/course_repository.dart';
import 'package:art_mobile/features/courses/data/repositories/course_repository_impl.dart';
import 'package:art_mobile/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:art_mobile/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:art_mobile/features/supply/domain/repositories/supply_repository.dart';
import 'package:art_mobile/features/supply/data/repositories/supply_repository_impl.dart';
import 'package:art_mobile/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:art_mobile/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:art_mobile/features/video_player/data/s3_video_service.dart';
import 'package:art_mobile/features/video_player/data/video_progress_service.dart';
import 'package:art_mobile/features/payment/services/razorpay_service.dart';
import 'package:art_mobile/features/payment/domain/repositories/payment_repository.dart';
import 'package:art_mobile/features/payment/data/repositories/payment_repository_impl.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External - SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // External - FlutterSecureStorage
  const secureStorage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);
  
  sl.registerSingleton<SecureStorageService>(SecureStorageService(secureStorage));

  // Theme Manager
  sl.registerSingleton<ThemeManager>(ThemeManager(sharedPreferences));

  // Device Service
  final deviceService = DeviceService();
  await deviceService.init();
  sl.registerSingleton<DeviceService>(deviceService);

  // Network Layer
  _setupNetworkLayer();

  // Services
  final firebaseAuthService = FirebaseAuthService();
  sl.registerLazySingleton<FirebaseAuthService>(() => firebaseAuthService);
  
  sl.registerLazySingleton<FcmService>(() => FcmService(sl<SecureStorageService>()));

  // Repositories
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<IAuthRemoteDataSource>(),
      firebaseAuthService: sl<FirebaseAuthService>(),
      deviceService: sl<DeviceService>(),
      secureStorageService: sl<SecureStorageService>(),
    ),
  );
  
  sl.registerLazySingleton<ICourseRepository>(
    () => CourseRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<ISubscriptionRepository>(
    () => SubscriptionRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<ISupplyRepository>(
    () => SupplyRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<INotificationsRepository>(
    () => NotificationsRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Video Player — Production S3/CloudFront URL service
  sl.registerLazySingleton<S3VideoService>(
      () => S3VideoService(
    apiClient: sl<ApiClient>(),
    cloudFrontBaseUrl: EnvironmentConfig.cloudFrontBaseUrl,
  ));

  // Video Progress Tracker
  sl.registerSingleton<VideoProgressService>(VideoProgressService(sl<SharedPreferences>()));

  // Payment Repository
  sl.registerLazySingleton<IPaymentRepository>(
    () => PaymentRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Payment
  sl.registerFactory<RazorpayService>(() => RazorpayService());
}

void _setupNetworkLayer() {
  final dio = Dio();

  // ---------------------------------------------------------------------------
  // SSL Certificate validation
  // ---------------------------------------------------------------------------
  // Only bypass SSL in development (local servers / ngrok without a valid cert).
  // In staging and production we connect to https://api.gloriousartcreations.com
  // which has a valid TLS certificate — strict validation must be ON.
  // EnvironmentConfig.allowSelfSignedCertificates returns true ONLY when
  // ENV=development (i.e. the default `flutter run` without any --dart-define).
  // ---------------------------------------------------------------------------
  if (EnvironmentConfig.allowSelfSignedCertificates) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  // Interceptors — auth token injection, retry logic, and error mapping.
  // Network logs are only added in development/staging to avoid leaking
  // request bodies and tokens in production logcat output.
  
  if (!kDebugMode && !EnvironmentConfig.allowSelfSignedCertificates) {
    dio.interceptors.add(
      CertificatePinningInterceptor(allowedSHAFingerprints: [
        // TODO: Replace with your actual server SHA-256 fingerprint
        "XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"
      ]),
    );
  }

  dio.interceptors.addAll([
    AuthInterceptor(secureStorage: sl<SecureStorageService>(), dio: dio),
    RetryInterceptor(dio: dio),
    ErrorInterceptor(),
  ]);

  sl.registerSingleton<Dio>(dio);
  sl.registerSingleton<ApiClient>(ApiClient(dio: dio));
}
