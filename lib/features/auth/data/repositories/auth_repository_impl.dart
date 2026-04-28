import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, OtpRequestResponse>> requestOtp(String phone) async {
    try {
      debugPrint('🔑 Requesting OTP for $phone');
      final response = await apiClient.post(
        'auth/otp/request',
        data: {'phone': phone},
      );
      
      if (response.data != null) {
        debugPrint('🔓 OTP Request Successful: ${response.data}');
        return Right(OtpRequestResponse.fromJson(response.data));
      } else {
        debugPrint('⚠️ OTP Request: Empty response');
        return const Left(ServerFailure(message: 'Empty response from server'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OtpVerifyResponse>> verifyOtp(String phone, String otp, {String? name, String? sessionId}) async {
    try {
      debugPrint('🔑 Verifying OTP for $phone | OTP: $otp | Name: $name');
      final payload = {
        'phone': phone,
        'otp': otp,
      };
      if (name != null) payload['name'] = name;
      if (sessionId != null) payload['session_id'] = sessionId;

      final response = await apiClient.post(
        'auth/otp/verify',
        data: payload,
      );
      
      if (response.data != null) {
        debugPrint('🔓 OTP Verification Successful: ${response.data}');
        return Right(OtpVerifyResponse.fromJson(response.data));
      } else {
        debugPrint('⚠️ OTP Verification: Empty response');
        return const Left(ServerFailure(message: 'Empty response from server'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout || 
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure(message: 'Request timed out. Please try again.');
    } else if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure(message: 'No internet connection or server unreachable.');
    } else if (e.response != null) {
      final data = e.response?.data;
      String message = 'Server error occurred';
      
      if (data is Map) {
        message = data['message'] ?? data['error'] ?? data['detail'] ?? 'Server error occurred';
      }
      
      return ServerFailure(message: message, statusCode: e.response?.statusCode);
    } else {
      return const ServerFailure(message: 'No response from server. Please check your connection.');
    }
  }
}
