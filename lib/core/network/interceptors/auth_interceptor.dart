import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:art_mobile/core/constants/app_constants.dart';

class AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Retrieve token from secure storage
    final token = await secureStorage.read(key: AppConstants.accessTokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - refresh token
    if (err.response?.statusCode == 401) {
      // Token refresh logic can be implemented here
      // For now, redirect to login
    }

    return handler.next(err);
  }
}
