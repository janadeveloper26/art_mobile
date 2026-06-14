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

// Features
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:art_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:art_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:art_mobile/features/auth/services/firebase_auth_service.dart';
import 'package:art_mobile/features/courses/data/mock_course_service.dart'; // Still needed for interface
import 'package:art_mobile/features/courses/data/repositories/course_repository_impl.dart';
import 'package:art_mobile/features/subscription/data/mock_subscription_repository.dart'; // Still needed for interface
import 'package:art_mobile/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:art_mobile/features/video_player/data/s3_video_service.dart';
import 'package:art_mobile/features/payment/services/razorpay_service.dart';

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

  // Video Player — Production S3/CloudFront URL service
  sl.registerLazySingleton<S3VideoService>(
      () => S3VideoService(
    apiClient: sl<ApiClient>(),
    cloudFrontBaseUrl: EnvironmentConfig.cloudFrontBaseUrl,
  ));

  // Payment
  sl.registerFactory<RazorpayService>(() => RazorpayService());
}

void _setupNetworkLayer() {
  // Dio
  final dio = Dio();
  
  // Bypass SSL certificate validation for development backend
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );

  // Interceptors
  dio.interceptors.addAll([
    AuthInterceptor(secureStorage: sl<SecureStorageService>(), dio: dio),
    RetryInterceptor(dio: dio),
    ErrorInterceptor(),
  ]);

  sl.registerSingleton<Dio>(dio);

  // API Client
  sl.registerSingleton<ApiClient>(ApiClient(dio: dio));
}
