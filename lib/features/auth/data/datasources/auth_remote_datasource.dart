import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';
import 'package:dio/dio.dart';

abstract class IAuthRemoteDataSource {
  Future<OtpData> requestOtp(String phone);
  Future<AuthData> verifyOtp(OtpVerifyRequest request);
  Future<AuthData> firebaseLogin(FirebaseLoginRequest request);
  Future<bool> checkApprovalStatus();
  Future<UserData> getProfile();
  Future<UserData> updateProfile({String? name, String? email});
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<OtpData> requestOtp(String phone) async {
    final response = await apiClient.post(
      'auth/send-otp',
      data: {'phone_number': phone},
    );

    if (_isSuccess(response.data)) {
      return OtpData.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: 'auth/send-otp'),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<AuthData> verifyOtp(OtpVerifyRequest request) async {
    final response = await apiClient.post(
      'auth/otp/verify',
      data: request.toJson(),
    );

    if (_isSuccess(response.data)) {
      return AuthData.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: 'auth/otp/verify'),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<AuthData> firebaseLogin(FirebaseLoginRequest request) async {
    final response = await apiClient.post(
      'auth/firebase/login',
      data: request.toJson(),
    );
    
    if (_isSuccess(response.data)) {
      return AuthData.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: 'auth/firebase/login'),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<bool> checkApprovalStatus() async {
    final response = await apiClient.get('auth/device/approval-status');
    if (_isSuccess(response.data)) {
      return response.data['data']['is_approved'] == true;
    } else {
      throw DioException(
        requestOptions: RequestOptions(path: 'auth/device/approval-status'),
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<UserData> getProfile() async {
    final response = await apiClient.get('profile');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final userData = data['data'] ?? data['user'] ?? data;
      if (userData is Map<String, dynamic>) {
        return UserData.fromJson(userData);
      }
    }
    throw DioException(
      requestOptions: RequestOptions(path: 'profile'),
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<UserData> updateProfile({String? name, String? email}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;

    final response = await apiClient.put('profile', data: body);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final userData = data['data'] ?? data['user'] ?? data;
      if (userData is Map<String, dynamic>) {
        return UserData.fromJson(userData);
      }
    }
    throw DioException(
      requestOptions: RequestOptions(path: 'profile'),
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  bool _isSuccess(dynamic data) {
    if (data is! Map<String, dynamic>) return false;
    return data['success'] == true || data['status'] == 'success';
  }
}
