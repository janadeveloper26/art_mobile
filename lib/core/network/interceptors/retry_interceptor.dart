import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retries'] == null) {
      err.requestOptions.extra['retries'] = 0;
    }

    if (_shouldRetry(err) && (err.requestOptions.extra['retries'] as int) < maxRetries) {
      int retries = err.requestOptions.extra['retries'] as int;
      err.requestOptions.extra['retries'] = retries + 1;
      
      // Check connectivity before retrying
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return handler.next(err); // Fail fast if offline
      }

      try {
        await Future.delayed(Duration(seconds: 1 * retries)); // Exponential backoff

        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.connectionError;
  }
}
