import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';
import 'package:art_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient apiClient;
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, OtpData>> requestOtp(String phone) async {
    try {
      debugPrint('🔑 Requesting OTP for $phone');
      final result = await remoteDataSource.requestOtp(phone);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthData>> verifyOtp({
    required String idToken,
    String? name,
    required DeviceMetadata device,
  }) async {
    try {
      debugPrint('🔑 Verifying OTP via token | Name: $name');
      final request = OtpVerifyRequest(idToken: idToken, name: name, device: device);
      final result = await remoteDataSource.verifyOtp(request);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthData>> firebaseLogin(String idToken, DeviceMetadata device) async {
    try {
      final request = FirebaseLoginRequest(idToken: idToken, device: device);
      final result = await remoteDataSource.firebaseLogin(request);
      return Right(result);
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
