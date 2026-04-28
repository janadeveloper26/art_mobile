import 'package:dartz/dartz.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';

abstract class IAuthRepository {
  Future<Either<Failure, OtpRequestResponse>> requestOtp(String phone);
  Future<Either<Failure, OtpVerifyResponse>> verifyOtp(String phone, String otp, {String? name, String? sessionId});
}
