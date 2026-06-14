import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Razorpay payment service for course enrollment.
/// Pass --dart-define=RAZORPAY_KEY=rzp_live_xxx at build time to override.
class RazorpayService {
  // Read at compile time via --dart-define=RAZORPAY_KEY=...
  // Default is Razorpay test key — REPLACE before going live.
  static const String _key = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_YourKeyHere',
  );

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
  ///
  /// [amountInRupees] — e.g. 999.0
  /// [courseName]     — shown in the checkout description
  /// [userPhone]      — pre-fills the phone field (with country code, e.g. +919876543210)
  /// [userEmail]      — pre-fills the email field
  /// [userId]         — used in notes for webhook identification
  void openCheckout({
    required double amountInRupees,
    required String courseName,
    required String userPhone,
    String? userEmail,
    String? userId,
  }) {
    final options = <String, dynamic>{
      'key': _key,
      // Razorpay expects amount in **paise** (multiply rupees by 100)
      'amount': (amountInRupees * 100).toInt(),
      'currency': 'INR',
      'name': 'AariLearn',
      'description': courseName,
      'prefill': {
        'contact': userPhone,
        if (userEmail != null && userEmail.isNotEmpty) 'email': userEmail,
      },
      'notes': {
        'user_id': userId ?? '',
        'course_name': courseName,
      },
      'theme': {
        'color': '#6A1B9A',
      },
      // Webhook verification is done server-side using your Razorpay webhook secret
      // Configure webhook at: https://dashboard.razorpay.com/app/webhooks
      // Event: payment.captured → POST /api/v1/payments/webhook/razorpay
    };

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
