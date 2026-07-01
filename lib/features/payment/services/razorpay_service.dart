import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Razorpay payment service for course enrollment.
/// Pass --dart-define=RAZORPAY_KEY=rzp_live_xxx at build time to override.
class RazorpayService {
  final Razorpay _razorpay = Razorpay();

  // Callbacks to be set by the caller
  void Function(PaymentSuccessResponse)? onSuccess;
  void Function(PaymentFailureResponse)? onFailure;
  void Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Opens the Razorpay checkout sheet.
  void openCheckout({
    required String gatewayKey,
    String? orderId,
    String? subscriptionId,
    double? amountInRupees,
    required String courseName,
    required String userPhone,
    String? userEmail,
    String? userId,
  }) {
    final options = <String, dynamic>{
      'key': gatewayKey,
      'currency': 'INR',
      'name': 'AariLearn',
      'description': courseName,
      'prefill': {
        'contact': userPhone.isEmpty ? '9999999999' : userPhone,
        if (userEmail != null && userEmail.isNotEmpty) 'email': userEmail else 'email': 'test@example.com',
      },
      'notes': {
        'user_id': userId ?? '',
        'course_name': courseName,
      },
      'theme': {
        'color': '#6A1B9A',
      },
    };

    if (orderId != null) {
      options['order_id'] = orderId;
    }
    
    if (subscriptionId != null) {
      options['subscription_id'] = subscriptionId;
    } else if (amountInRupees != null) {
      options['amount'] = (amountInRupees * 100).toInt();
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      onFailure?.call(PaymentFailureResponse(0, e.toString(), null));
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    onSuccess?.call(response);
  }

  void _handleFailure(PaymentFailureResponse response) {
    onFailure?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call(response);
  }

  /// Call this when the page that uses [RazorpayService] is disposed.
  void dispose() {
    _razorpay.clear();
  }
}
