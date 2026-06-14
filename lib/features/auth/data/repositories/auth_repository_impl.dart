import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
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
      debugPrint('🔑 Requesting OTP via backend for $phoneNumber');
      final otpData = await remoteDataSource.requestOtp(phoneNumber);
      if (!otpData.canProceed) {
        return const Left(ServerFailure(message: 'Cannot proceed with OTP request.'));
      }

      await firebaseAuthService.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
      );

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Failed to send OTP via Firebase.'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
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
      debugPrint('🔑 Verifying OTP via backend');
      final idToken = await firebaseAuthService.verifyOtp(
        verificationId: verificationId,
        otp: otp,
      );

      return await _processDjangoOtpAuth(idToken, name: name);
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

  Future<Either<Failure, AuthData>> _processDjangoOtpAuth(
    String idToken, {
    String? name,
  }) async {
    try {
      final device = await _buildDeviceMetadata();
      final request = OtpVerifyRequest(
        idToken: idToken,
        name: name,
        device: device,
      );
      final result = await remoteDataSource.verifyOtp(request);

      await secureStorageService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await secureStorageService.saveUserData(result.user.toJsonString());

      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, AuthData>> _processDjangoAuth(String idToken, {required bool isGoogle, String? name}) async {
    try {
      final device = await _buildDeviceMetadata();

      AuthData result;
      if (isGoogle) {
        final request = FirebaseLoginRequest(idToken: idToken, device: device);
        result = await remoteDataSource.firebaseLogin(request);
      } else {
        throw UnsupportedError('OTP auth must use sendOtp and verifyOtp.');
      }

      await secureStorageService.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await secureStorageService.saveUserData(result.user.toJsonString());

      return Right(result);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<DeviceMetadata> _buildDeviceMetadata() async {
    final deviceInfoMap = await deviceService.getDeviceInfo();
    return DeviceMetadata(
      deviceId: deviceInfoMap['device_id'],
      deviceName: deviceInfoMap['device_name'],
      manufacturer: deviceInfoMap['manufacturer'],
      brand: deviceInfoMap['brand'],
      androidVersion: deviceInfoMap['android_version'],
      platform: deviceInfoMap['platform'],
      fcmToken: deviceInfoMap['fcm_token'],
    );
  }

  @override
  Future<Either<Failure, bool>> checkApprovalStatus() async {
    try {
      debugPrint('🔑 Checking approval status via backend');
      final isApproved = await remoteDataSource.checkApprovalStatus();
      return Right(isApproved);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserData>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      await secureStorageService.saveUserData(user.toJsonString());
      return Right(user);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserData>> updateProfile({String? name, String? email}) async {
    try {
      final user = await remoteDataSource.updateProfile(name: name, email: email);
      await secureStorageService.saveUserData(user.toJsonString());
      return Right(user);
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
