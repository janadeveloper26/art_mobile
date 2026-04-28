import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:art_mobile/core/network/interceptors/error_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';

// Features
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:art_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:art_mobile/features/courses/data/mock_course_service.dart'; // Still needed for interface
import 'package:art_mobile/features/courses/data/repositories/course_repository_impl.dart';
import 'package:art_mobile/features/subscription/data/mock_subscription_repository.dart'; // Still needed for interface
import 'package:art_mobile/features/subscription/data/repositories/subscription_repository_impl.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External - SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // External - FlutterSecureStorage
  const secureStorage = FlutterSecureStorage();
  sl.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Theme Manager
  sl.registerSingleton<ThemeManager>(ThemeManager(sharedPreferences));

  // Network Layer
  _setupNetworkLayer();

  // Repositories
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(apiClient: sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<ICourseRepository>(
    () => CourseRepositoryImpl(apiClient: sl<ApiClient>()),
  );
  
  sl.registerLazySingleton<ISubscriptionRepository>(
    () => SubscriptionRepositoryImpl(apiClient: sl<ApiClient>()),
  );
}

void _setupNetworkLayer() {
  // Dio
  final dio = Dio();

  // Interceptors
  dio.interceptors.addAll([
    AuthInterceptor(sl<FlutterSecureStorage>()),
    ErrorInterceptor(),
  ]);

  sl.registerSingleton<Dio>(dio);

  // API Client
  sl.registerSingleton<ApiClient>(ApiClient(dio: dio));
}
