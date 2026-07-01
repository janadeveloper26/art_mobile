import 'package:dartz/dartz.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/features/payment/data/models/payment_models.dart';

abstract class IPaymentRepository {
  Future<Either<Failure, CourseOrderResponse>> createCourseOrder(String courseId);
  
  Future<Either<Failure, void>> verifyCoursePayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  Future<Either<Failure, SubscriptionOrderResponse>> createSubscription(String planId);

  Future<Either<Failure, void>> verifySubscriptionPayment({
    required String razorpaySubscriptionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
}
