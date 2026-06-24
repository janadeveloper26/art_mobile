import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:art_mobile/core/config/environment.dart';

class ErrorInterceptor extends QueuedInterceptor {
  final logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = _getErrorMessage(err);

    // OLD LOGIC:
    // logger.e(
    //   'API Error: ${err.response?.statusCode} - $message'
    //   '\nURL: ${err.requestOptions.path}'
    //   '\nResponse body: ${err.response?.data}',
    // );
    
    if (EnvironmentConfig.enableNetworkLogs) {
      logger.e(
        'API Error: ${err.response?.statusCode} - $message'
        '\nURL: ${err.requestOptions.path}'
        '\nResponse body: ${err.response?.data}',
      );
    } else {
      logger.e('API Error: ${err.response?.statusCode} - $message | URL: ${err.requestOptions.path}');
    }

    return handler.next(err);
  }

  String _getErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return _getHttpErrorMessage(err.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error: ${err.error}';
      default:
        return 'An unexpected error occurred.';
    }
  }

  String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'You do not have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'Conflict. This resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Server error ($statusCode). Please try again later.';
    }
  }
}
