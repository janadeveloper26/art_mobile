import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:art_mobile/core/errors/failures.dart';
import 'package:art_mobile/core/network/api_client.dart';
import 'package:art_mobile/features/payment/data/models/payment_models.dart';
import 'package:art_mobile/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements IPaymentRepository {
  final ApiClient apiClient;

  PaymentRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, CourseOrderResponse>> createCourseOrder(String courseId) async {
    try {
      final response = await apiClient.post(
        '/payments/courses/create-order',
        data: {'course_id': courseId},
      );
      
      if (response.data['success'] == true) {
        return Right(CourseOrderResponse.fromJson(response.data['data']));
      } else {
        return Left(ServerFailure(message: response.data['message'] ?? 'Failed to create order'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyCoursePayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await apiClient.post(
        '/payments/courses/verify',
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      
      if (response.data['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.data['message'] ?? 'Failed to verify payment'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionOrderResponse>> createSubscription(String planId) async {
    try {
      final response = await apiClient.post(
        '/payments/subscriptions/create',
        data: {'plan_id': planId},
      );
      
      if (response.data['success'] == true) {
        return Right(SubscriptionOrderResponse.fromJson(response.data['data']));
      } else {
        return Left(ServerFailure(message: response.data['message'] ?? 'Failed to create subscription'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifySubscriptionPayment({
    required String razorpaySubscriptionId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await apiClient.post(
        '/payments/subscriptions/verify',
        data: {
          'razorpay_subscription_id': razorpaySubscriptionId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      
      if (response.data['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.data['message'] ?? 'Failed to verify subscription'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Network Error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
