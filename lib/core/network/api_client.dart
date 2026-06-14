import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:art_mobile/core/config/environment.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required this.dio}) {
    _setupDio();
  }

  void _setupDio() {
    dio.options
      ..baseUrl = EnvironmentConfig.baseUrl
      ..connectTimeout = EnvironmentConfig.connectTimeout
      ..receiveTimeout = EnvironmentConfig.receiveTimeout
      ..sendTimeout = EnvironmentConfig.sendTimeout
      ..contentType = 'application/json'
      ..responseType = ResponseType.json;
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      debugPrint('🚀 [GET] $path | Query: $queryParameters');
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      debugPrint('✅ [GET] SUCCESS $path | Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [GET] FAILED $path | Error: ${e.message}');
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      debugPrint('🚀 [POST] $path | Data: $data');
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      debugPrint('✅ [POST] SUCCESS $path | Status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      debugPrint('❌ [POST] FAILED $path | Error: ${e.message}');
      if (e.response != null) {
        debugPrint('❌ [POST] FAILED Response Body: ${e.response?.data}');
      }
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException {
      rethrow;
    }
  }

  // Download file
  Future<Response> download(
    String path,
    dynamic savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException {
      rethrow;
    }
  }
}
