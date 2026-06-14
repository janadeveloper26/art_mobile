import 'package:dartz/dartz.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/features/auth/data/models/auth_models.dart';

abstract class IAuthRepository {
  Future<Either<Failure, void>> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  });
  
  Future<Either<Failure, AuthData>> verifyOtp({
    required String verificationId,
    required String otp,
    String? name,
  });
  
  Future<Either<Failure, AuthData>> signInWithGoogle();
  
  Future<Either<Failure, bool>> checkApprovalStatus();

  Future<Either<Failure, UserData>> getProfile();

  Future<Either<Failure, UserData>> updateProfile({String? name, String? email});
}
