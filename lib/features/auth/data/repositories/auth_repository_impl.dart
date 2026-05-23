import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';
import 'package:art_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:art_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:art_mobile/features/auth/services/firebase_auth_service.dart';
import 'package:art_mobile/core/services/device_service.dart';
import 'package:art_mobile/core/storage/secure_storage_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final FirebaseAuthService firebaseAuthService;
  final DeviceService deviceService;
  final SecureStorageService secureStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuthService,
    required this.deviceService,
    required this.secureStorageService,
  });

  @override
  Future<Either<Failure, void>> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  }) async {
    try {
      debugPrint('🔑 Requesting OTP via Firebase for $phoneNumber');
      await firebaseAuthService.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthData>> verifyOtp({
    required String verificationId,
    required String otp,
    String? name,
  }) async {
    try {
      debugPrint('🔑 Verifying OTP via Firebase');
      final idToken = await firebaseAuthService.verifyOtp(
        verificationId: verificationId,
        otp: otp,
      );

      return await _processDjangoAuth(idToken, isGoogle: false, name: name);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthData>> signInWithGoogle() async {
    try {
      debugPrint('🔑 Initiating Google Sign In');
      final idToken = await firebaseAuthService.signInWithGoogle();
      
      return await _processDjangoAuth(idToken, isGoogle: true);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AuthData>> _processDjangoAuth(String idToken, {required bool isGoogle, String? name}) async {
    try {
      final deviceInfoMap = await deviceService.getDeviceInfo();
      final device = DeviceMetadata(
        deviceId: deviceInfoMap['device_id'],
        deviceName: deviceInfoMap['device_name'],
        manufacturer: deviceInfoMap['manufacturer'],
        brand: deviceInfoMap['brand'],
        androidVersion: deviceInfoMap['android_version'],
        platform: deviceInfoMap['platform'],
        fcmToken: deviceInfoMap['fcm_token'],
      );

      AuthData result;
      if (isGoogle) {
        final request = FirebaseLoginRequest(idToken: idToken, device: device);
        result = await remoteDataSource.firebaseLogin(request);
      } else {
        final request = OtpVerifyRequest(idToken: idToken, name: name, device: device);
        result = await remoteDataSource.verifyOtp(request);
      }

      await secureStorageService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

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
