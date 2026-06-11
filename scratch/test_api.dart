import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void main() async {
  print('Testing Django Backend API...');
  
  final dio = Dio(BaseOptions(
    baseUrl: 'https://10.59.146.179:8000/api/v1/', // Using the IP from your logs
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
    }
  ));

  // Bypass SSL
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );

  try {
    // We send an invalid token to verify we get a clean 401 error,
    // which proves the endpoint is reachable, accepts the payload format, 
    // and returns the expected schema instead of crashing!
    final response = await dio.post(
      'auth/firebase/login',
      data: {
        'firebase_token': 'fake_token_to_verify_contract',
        'device': {
          'device_id': 'test-123',
          'device_name': 'AI Test Device',
          'manufacturer': 'Google',
          'brand': 'Android',
          'android_version': '14',
          'platform': 'android',
          'fcm_token': 'fake-fcm',
        }
      },
    );
    
    print('Response Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
  } on DioException catch (e) {
    print('Response Code: ${e.response?.statusCode}');
    print('Response Data: ${e.response?.data}');
  } catch (e) {
    print('Unexpected Error: $e');
  }
}
