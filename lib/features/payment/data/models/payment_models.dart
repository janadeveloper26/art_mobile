import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_models.freezed.dart';
part 'payment_models.g.dart';

@freezed
class CourseOrderResponse with _$CourseOrderResponse {
  const factory CourseOrderResponse({
    @JsonKey(name: 'order_id') required String orderId,
    required int amount,
    required String currency,
    required String status,
    @JsonKey(name: 'gateway_key') required String gatewayKey,
  }) = _CourseOrderResponse;

  factory CourseOrderResponse.fromJson(Map<String, dynamic> json) => _$CourseOrderResponseFromJson(json);
}

@freezed
class SubscriptionOrderResponse with _$SubscriptionOrderResponse {
  const factory SubscriptionOrderResponse({
    @JsonKey(name: 'subscription_id') required String subscriptionId,
    required String status,
    @JsonKey(name: 'gateway_key') required String gatewayKey,
  }) = _SubscriptionOrderResponse;

  factory SubscriptionOrderResponse.fromJson(Map<String, dynamic> json) => _$SubscriptionOrderResponseFromJson(json);
}
