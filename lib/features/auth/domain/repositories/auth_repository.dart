import 'package:dartz/dartz.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';

abstract class IAuthRepository {
  Future<Either<Failure, OtpData>> requestOtp(String phone);
  Future<Either<Failure, AuthData>> verifyOtp({
    required String idToken,
    String? name,
    required DeviceMetadata device,
  });
  Future<Either<Failure, AuthData>> firebaseLogin(String idToken, DeviceMetadata device);
}
