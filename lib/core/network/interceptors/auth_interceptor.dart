import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:art_mobile/core/storage/secure_storage_service.dart';
import 'package:art_mobile/core/constants/app_constants.dart';
import 'package:art_mobile/core/config/environment.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService secureStorage;
  late final Dio _refreshDio;

  AuthInterceptor({required this.secureStorage, required this.dio}) {
    _refreshDio = Dio(BaseOptions(baseUrl: EnvironmentConfig.baseUrl));
    _refreshDio.interceptors.clear();
    _refreshDio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  /// Prevent multiple concurrent refresh attempts
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();

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
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return handler.next(err);
    }

    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await secureStorage.clearAll();
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final response = await _refreshDio.post(
        AppConstants.refreshTokenEndpoint.replaceFirst('/', ''),
        data: {'refresh': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final newAccess = response.data['access'] as String? ??
          response.data['access_token'] as String?;
      final newRefresh = response.data['refresh'] as String? ??
          response.data['refresh_token'] as String?;

      if (newAccess == null) {
        await secureStorage.clearAll();
        return handler.next(err);
      }

      await secureStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh ?? refreshToken,
      );

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await dio.fetch(err.requestOptions);
      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      await secureStorage.clearAll();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
